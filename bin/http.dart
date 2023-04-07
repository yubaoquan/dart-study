import 'dart:io';
import 'package:path/path.dart' as path;
import 'package:http/http.dart' as http;

void main() async {
  requestAndSave('https://baidu.com', getAbsoluteFilePath('../temp/baidu.html'));
  requestAndSave(
    'https://element.eleme.io/#/zh-CN/component/installation',
    getAbsoluteFilePath('../temp/element-ui.html'),
  );
}

String getAbsoluteFilePath(String relativePath) {
  final dirname = path.dirname(Platform.script.toFilePath(windows: Platform.isWindows));
  return path.join(dirname, relativePath);
}

void requestAndSave(String url, String filePath) async {
  final httpPackageUrl = Uri.parse(url);
  final httpPackageResponse = await http.get(httpPackageUrl);
  if (httpPackageResponse.statusCode != 200) {
    print('Failed to retrieve the http package!');
    return;
  }

  writeToFile(httpPackageResponse.body, filePath);
}

void writeToFile(String content, String filePath) async {
  final file = File(filePath).openWrite(mode: FileMode.write);
  file.write(content);
  await file.close();
  print('Response saved to file $filePath');
}
