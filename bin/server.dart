library dartmud.server;

import 'dart:io';

import 'package:path/path.dart' as path;

main() async {
  var webPath =  path.join(Directory.current.path, 'web');
  var webDir = new Directory(webPath);
  print(webPath);
  var exists = await webDir.exists();
  if (!exists) {
    print('Error: unable to find web directory');
    exit(1);
  }

  var server = await HttpServer.bind(InternetAddress.ANY_IP_V4, 8080);
  await for (HttpRequest req in server) {
    var reqPath = req.uri.normalizePath();
    if (reqPath.path == '/ws') {
      if (WebSocketTransformer.isUpgradeRequest(req)) {
        // Websocket connection
        print('Upgraded');
        var wsReq = await WebSocketTransformer.upgrade(req);
      } else {
        print('Fake websocket request detected');
        req.response.close();
        continue;
      }
    } else {
      var filePath = reqPath.path;
      if (filePath == '/') {
        filePath = path.join(filePath, 'index.html');
      }
      filePath = path.join(webPath, filePath.substring(1));
      var reqFile = new File(filePath);
      var validFile = await reqFile.exists();
      if (validFile) {
        print('$filePath exists');
        req.response.statusCode = HttpStatus.OK;
        req.response.headers.contentType = ContentType.HTML; 
        await reqFile.openRead().pipe(req.response);
      } else {
        print('$filePath Does not exist');
        req.response.statusCode = HttpStatus.NOT_FOUND;
        req.response.write('Not Found');
      }
    }
    req.response.close();
  }
}
