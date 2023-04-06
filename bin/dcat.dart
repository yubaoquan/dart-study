import 'dart:convert';
import 'dart:io';

import 'package:args/args.dart';

const lineNumber = 'line-number';

void main(List<String> arguments) {
  exitCode = 0; // presume success
  if (!hasPermission()) return stdout.writeln('Password incorrect');

  final parser = ArgParser()..addFlag(lineNumber, negatable: false, abbr: 'n');

  ArgResults argResults = parser.parse(arguments);
  final paths = argResults.rest;

  dcat(paths, showLineNumbers: argResults[lineNumber] as bool);
}

/// Ask user to enter the password,
/// if passwork is wrong, terminate the program.
bool hasPermission() {
  stdout.writeln('Please enter password');
  final echoMode = stdin.echoMode;
  stdin.echoMode = false;

  final password = stdin.readLineSync();

  stdin.echoMode = echoMode;

  return password == 'zmkm';
}

Future<void> dcat(List<String> paths, {bool showLineNumbers = false}) async {
  if (paths.isEmpty) {
    // No files provided as arguments. Read from stdin and print each line.
    await stdin.pipe(stdout);
  } else {
    for (final path in paths) {
      var lineNumber = 1;
      final lines = utf8.decoder.bind(File(path).openRead()).transform(const LineSplitter());
      try {
        await for (final line in lines) {
          if (showLineNumbers) {
            stdout.write('${lineNumber++} ');
          }
          stdout.writeln(line);
        }
      } catch (_) {
        await _handleError(path);
      }
    }
  }
}

Future<void> _handleError(String path) async {
  if (await FileSystemEntity.isDirectory(path)) {
    return stderr.writeln('error: $path is a directory');
  }

  if (!File(path).existsSync()) {
    return stderr.writeln('File $path not exists.');
  }

  stderr.writeln('Unknown error');
  exitCode = 2;
}
