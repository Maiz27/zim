import 'package:flutter/material.dart';
import 'package:provider/provider.dart';
import 'package:zim/widgets/storage_section.dart';

import '../../providers/core_provider.dart';
import '../../widgets/app_drawer.dart';
import '../../widgets/category_section.dart';
import '../search.dart';

class Browse extends StatefulWidget {
  const Browse({super.key});

  @override
  State<Browse> createState() => _BrowseState();
}

class _BrowseState extends State<Browse> {
  refresh(BuildContext context) async {
    await Provider.of<CoreProvider>(context, listen: false).checkSpace();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      appBar: AppBar(
        centerTitle: true,
        title: const Text(
          'Zim',
          style: TextStyle(fontSize: 25.0),
        ),
        actions: [
          IconButton(
            tooltip: 'Search',
            onPressed: () {
              showSearch(
                context: context,
                delegate: Search(themeData: Theme.of(context)),
              );
            },
            icon: const Icon(Icons.search),
          )
        ],
      ),
      drawer: const AppDrawer(),
      body: RefreshIndicator(
        onRefresh: () => refresh(context),
        child: Column(
          // mainAxisAlignment: MainAxisAlignment.spaceEvenly,
          children: const [
            StorageSection(),
            CategorySection(),
          ],
        ),
      ),
    );
  }

  calculatePercent(int usedSpace, int totalSpace) {
    return double.parse((usedSpace / totalSpace * 100).toStringAsFixed(1));
  }
}

// class _CategoriesSection extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return ListView.separated(
//       shrinkWrap: true,
//       physics: const NeverScrollableScrollPhysics(),
//       itemCount: Constants.categories.length,
//       itemBuilder: (BuildContext context, int index) {
//         Map category = Constants.categories[index];

//         return ListTile(
//           onTap: () {
//             if (index == 0) {
//               Navigate.pushPage(
//                   context, Downloads(title: '${category['title']}'));
//             } else if (index == 5) {
//               Navigate.pushPage(context, const AppScreen());
//             } else {
//               Navigate.pushPage(
//                 context,
//                 index == 1 || index == 2
//                     ? Images(title: '${category['title']}')
//                     : Category(title: '${category['title']}'),
//               );
//             }
//           },
//           contentPadding: const EdgeInsets.all(0),
//           leading: Container(
//             height: 40,
//             width: 40,
//             decoration: BoxDecoration(
//               shape: BoxShape.circle,
//               border: Border.all(
//                 color: Theme.of(context).dividerColor,
//                 width: 2,
//               ),
//             ),
//             child: Icon(category['icon'], size: 18, color: category['color']),
//           ),
//           title: Text('${category['title']}'),
//         );
//       },
//       separatorBuilder: (BuildContext context, int index) {
//         return CustomDivider();
//       },
//     );
//   }
// }

// class _RecentFiles extends StatelessWidget {
//   @override
//   Widget build(BuildContext context) {
//     return Consumer<CoreProvider>(
//       builder: (BuildContext context, coreProvider, Widget? child) {
//         if (coreProvider.recentLoading) {
//           return SizedBox(height: 150, child: CustomLoader());
//         }
//         return ListView.separated(
//           padding: const EdgeInsets.only(right: 20),
//           shrinkWrap: true,
//           physics: const NeverScrollableScrollPhysics(),
//           itemCount: coreProvider.recentFiles.length > 5
//               ? 5
//               : coreProvider.recentFiles.length,
//           itemBuilder: (BuildContext context, int index) {
//             FileSystemEntity file = coreProvider.recentFiles[index];
//             return file.existsSync() ? FileItem(file: file) : const SizedBox();
//           },
//           separatorBuilder: (BuildContext context, int index) {
//             return Container(
//               height: 1,
//               color: Theme.of(context).dividerColor,
//             );
//           },
//         );
//       },
//     );
//   }
// }
