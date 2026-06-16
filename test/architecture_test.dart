import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:zim/models/entry.dart';
import 'package:zim/providers/category_provider.dart';
import 'package:zim/services/file_repository.dart';
import 'package:zim/utils/design_tokens.dart';
import 'package:zim/utils/file_utils.dart';

void main() {
  group('CategoryProvider.classify (pure)', () {
    final entries = [
      '/storage/emulated/0/Download/installer.apk',
      '/storage/emulated/0/Music/song.mp3',
      '/storage/emulated/0/Docs/report.pdf',
      '/storage/emulated/0/Backups/data.zip',
    ].map((path) => Entry.of(File(path))).toList();

    test('filters apks and derives parent-dir tabs', () {
      final (files, tabs) = CategoryProvider.classify(entries, 'application');
      expect(files.length, 1);
      expect(files.first.path.endsWith('installer.apk'), isTrue);
      expect(tabs.first, 'All');
      expect(tabs, containsAll(<String>['All', 'Download']));
    });

    test('filters documents by extension', () {
      final (files, _) = CategoryProvider.classify(entries, 'text');
      expect(files.length, 1);
      expect(files.first.path.endsWith('report.pdf'), isTrue);
    });

    test('filters audio by mime type', () {
      final (files, _) = CategoryProvider.classify(entries, 'audio');
      expect(files.length, 1);
      expect(files.first.path.endsWith('song.mp3'), isTrue);
    });

    test('archive uses the shared (broad) extension set', () {
      final (files, _) = CategoryProvider.classify(entries, 'archive');
      expect(files.length, 1);
      expect(files.first.path.endsWith('data.zip'), isTrue);
    });
  });

  group('Entry.kindOf (pure classification)', () {
    test('classifies by extension before mime', () {
      expect(Entry.kindOf('/a/x.apk', isDir: false), FileKind.apk);
      expect(Entry.kindOf('/a/x.zip', isDir: false), FileKind.archive);
      expect(Entry.kindOf('/a/x.pdf', isDir: false), FileKind.document);
      expect(Entry.kindOf('/a/x.crdownload', isDir: false), FileKind.download);
    });

    test('falls back to mime type for media', () {
      expect(Entry.kindOf('/a/x.mp3', isDir: false), FileKind.audio);
      expect(Entry.kindOf('/a/x.jpg', isDir: false), FileKind.image);
      expect(Entry.kindOf('/a/x.mp4', isDir: false), FileKind.video);
    });

    test('directories are always folders', () {
      expect(Entry.kindOf('/a/sub', isDir: true), FileKind.folder);
    });
  });

  group('FileRepository.sortEntries', () {
    Entry e(String name, {int size = 0, int modMs = 0}) => Entry(
      path: '/p/$name',
      name: name,
      isDir: false,
      size: size,
      modified: DateTime.fromMillisecondsSinceEpoch(modMs),
      kind: FileKind.generic,
    );

    test('sorts by name ascending (case-insensitive) by default', () {
      final sorted = FileRepository.sortEntries([e('b'), e('A'), e('c')], 0);
      expect(sorted.map((x) => x.name).toList(), ['A', 'b', 'c']);
    });

    test('sorts by size descending (code 4)', () {
      final sorted = FileRepository.sortEntries(
        [e('s', size: 1), e('l', size: 9), e('m', size: 5)],
        4,
      );
      expect(sorted.map((x) => x.size).toList(), [9, 5, 1]);
    });

    test('sorts by modified descending (code 3)', () {
      final sorted = FileRepository.sortEntries(
        [e('old', modMs: 1), e('new', modMs: 9)],
        3,
      );
      expect(sorted.first.name, 'new');
    });
  });

  group('FileUtils.scanPaths (offloaded walk)', () {
    late Directory tmp;

    setUp(() async {
      tmp = await Directory.systemTemp.createTemp('zim_scan_test');
      File('${tmp.path}/top.txt').writeAsStringSync('x');
      File('${tmp.path}/.hidden.txt').writeAsStringSync('x');
      Directory('${tmp.path}/sub').createSync();
      File('${tmp.path}/sub/nested.txt').writeAsStringSync('x');
    });

    tearDown(() {
      if (tmp.existsSync()) tmp.deleteSync(recursive: true);
    });

    test('recurses into subdirectories and hides dotfiles by default', () {
      final found = FileUtils.scanPaths(([tmp.path], false));
      expect(found.any((p) => p.endsWith('top.txt')), isTrue);
      expect(found.any((p) => p.endsWith('nested.txt')), isTrue);
      expect(found.any((p) => p.endsWith('.hidden.txt')), isFalse);
    });

    test('includes dotfiles when showHidden is set', () {
      final found = FileUtils.scanPaths(([tmp.path], true));
      expect(found.any((p) => p.endsWith('.hidden.txt')), isTrue);
    });

    test('skips unreadable roots without throwing', () {
      final found = FileUtils.scanPaths((['${tmp.path}/does_not_exist'], false));
      expect(found, isEmpty);
    });
  });

  group('FileRepository', () {
    late Directory tmp;
    const repo = FileRepository();

    setUp(() async {
      tmp = await Directory.systemTemp.createTemp('zim_repo_test');
    });

    tearDown(() {
      if (tmp.existsSync()) tmp.deleteSync(recursive: true);
    });

    test('list hides dotfiles unless showHidden', () {
      File('${tmp.path}/visible.txt').writeAsStringSync('x');
      File('${tmp.path}/.secret').writeAsStringSync('x');

      expect(repo.list(tmp.path).length, 1);
      expect(repo.list(tmp.path, showHidden: true).length, 2);
    });

    test('createDirectory creates, then rejects duplicates', () async {
      final created = await repo.createDirectory(tmp.path, 'sub');
      expect(created.existsSync(), isTrue);

      await expectLater(
        repo.createDirectory(tmp.path, 'sub'),
        throwsA(
          isA<FileOpException>().having(
            (e) => e.kind,
            'kind',
            FileOpError.alreadyExists,
          ),
        ),
      );
    });

    test('rename moves the entity and rejects existing targets', () async {
      final original = File('${tmp.path}/a.txt')..writeAsStringSync('x');
      File('${tmp.path}/taken.txt').writeAsStringSync('x');

      final renamed = await repo.rename(original, 'b.txt');
      expect(renamed.path.endsWith('b.txt'), isTrue);
      expect(File('${tmp.path}/b.txt').existsSync(), isTrue);

      await expectLater(
        repo.rename(renamed, 'taken.txt'),
        throwsA(
          isA<FileOpException>().having(
            (e) => e.kind,
            'kind',
            FileOpError.alreadyExists,
          ),
        ),
      );
    });

    test('delete removes a file', () async {
      final f = File('${tmp.path}/gone.txt')..writeAsStringSync('x');
      await repo.delete(f);
      expect(f.existsSync(), isFalse);
    });

    test('extract rejects unsupported archive formats', () async {
      await expectLater(
        repo.extract('${tmp.path}/archive.rar', tmp.path),
        throwsA(
          isA<FileOpException>().having(
            (e) => e.kind,
            'kind',
            FileOpError.unsupported,
          ),
        ),
      );
    });
  });
}
