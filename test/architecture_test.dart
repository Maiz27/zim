import 'dart:io';

import 'package:flutter_test/flutter_test.dart';
import 'package:zim/providers/category_provider.dart';
import 'package:zim/services/file_repository.dart';

void main() {
  group('CategoryProvider.classify (pure)', () {
    final paths = [
      '/storage/emulated/0/Download/installer.apk',
      '/storage/emulated/0/Music/song.mp3',
      '/storage/emulated/0/Docs/report.pdf',
      '/storage/emulated/0/Backups/data.zip',
    ];

    test('filters apks and derives parent-dir tabs', () {
      final (files, tabs) = CategoryProvider.classify(paths, 'application');
      expect(files.length, 1);
      expect(files.first.path.endsWith('installer.apk'), isTrue);
      expect(tabs.first, 'All');
      expect(tabs, containsAll(<String>['All', 'Download']));
    });

    test('filters documents by extension', () {
      final (files, _) = CategoryProvider.classify(paths, 'text');
      expect(files.length, 1);
      expect(files.first.path.endsWith('report.pdf'), isTrue);
    });

    test('filters audio by mime type', () {
      final (files, _) = CategoryProvider.classify(paths, 'audio');
      expect(files.length, 1);
      expect(files.first.path.endsWith('song.mp3'), isTrue);
    });

    test('archive uses the shared (broad) extension set', () {
      final (files, _) = CategoryProvider.classify(paths, 'archive');
      expect(files.length, 1);
      expect(files.first.path.endsWith('data.zip'), isTrue);
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
