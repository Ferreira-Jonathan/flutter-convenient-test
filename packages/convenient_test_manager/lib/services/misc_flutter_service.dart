import 'package:convenient_test_manager/stores/highlight_store.dart';
import 'package:convenient_test_manager/stores/home_page_store.dart';
import 'package:convenient_test_manager_dart/services/misc_dart_service.dart';
import 'package:file_picker/file_picker.dart';
import 'package:get_it/get_it.dart';

class MiscFlutterService extends MiscDartService {
  @override
  void reloadInfo() {
    GetIt.I.get<HighlightStore>().enableAutoExpand = true;
    super.reloadInfo();
  }

  @override
  void clearAll() {
    super.clearAll();
    GetIt.I.get<HighlightStore>().clear();
  }

  Future<void> pickFileAndReadReport() async {
    final result = await FilePicker.platform.pickFiles(allowMultiple: false);
    if (result == null) return;

    final path = result.paths.single!;

    GetIt.I.get<HomePageStore>().displayLoadedReportMode = true;

    await readReportFromFile(path);
  }
}
