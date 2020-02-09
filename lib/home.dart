import 'package:camera/camera.dart';
import 'package:flutter/widgets.dart';
import 'package:just_camera/button.dart';
import 'package:just_camera/colors.dart';
import 'package:path/path.dart';
import 'package:path_provider/path_provider.dart';
import 'package:permission_handler/permission_handler.dart';

import 'icons.dart';

class HomeScreen extends StatefulWidget {
  const HomeScreen();

  @override
  _HomeScreenState createState() => _HomeScreenState();
}

class _HomeScreenState extends State<HomeScreen> {
  bool areAllPermissionsGranted = false;
  final PermissionHandler permissionHandler = PermissionHandler();

  CameraController _controller;
  Future<void> _initializeControllerFuture;

  bool isFlashOn = false;
  bool isRear = false;

  List<CameraDescription> cameras = <CameraDescription>[];

  @override
  void initState() {
    super.initState();

    checkPermission();
  }

  Future<void> checkPermission() async {
    final PermissionStatus cameraPermission =
        await permissionHandler.checkPermissionStatus(PermissionGroup.camera);

    final PermissionStatus storagePermission =
        await permissionHandler.checkPermissionStatus(PermissionGroup.storage);

    if (cameraPermission == PermissionStatus.granted &&
        storagePermission == PermissionStatus.granted) {
      setState(() {
        areAllPermissionsGranted = true;
      });

      initCamera();
    } else if (cameraPermission == PermissionStatus.denied ||
        storagePermission == PermissionStatus.denied) {
      permissionHandler.requestPermissions(<PermissionGroup>[
        PermissionGroup.camera,
        PermissionGroup.storage,
      ]);
    } else if (storagePermission == PermissionStatus.neverAskAgain ||
        storagePermission == PermissionStatus.neverAskAgain) {
      permissionHandler.openAppSettings();
    } else {
      // TOOD(lucky): this device doesn't support camera or saving image
    }
  }

  Future<void> initCamera() async {
    cameras = await availableCameras();

    if (cameras.isEmpty) {
      // TOOD(lucky): this device doesn't support camera or saving image
      return;
    }

    _controller = CameraController(
      isRear ? cameras.first : cameras.length > 1 ? cameras[1] : cameras.first,
      ResolutionPreset.max,
    );

    _initializeControllerFuture = _controller.initialize();
  }

  @override
  void dispose() {
    _controller.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Stack(
      fit: StackFit.passthrough,
      children: <Widget>[
        FutureBuilder<void>(
          future: _initializeControllerFuture,
          builder: (BuildContext context, AsyncSnapshot<void> snapshot) {
            if (snapshot.connectionState == ConnectionState.done) {
              return AspectRatio(
                aspectRatio: _controller.value.aspectRatio,
                child: Container(child: CameraPreview(_controller)),
              );
            } else {
              return const Center(child: Text('Loading Camera...'));
            }
          },
        ),
        Positioned(
          bottom: MediaQuery.of(context).padding.bottom + 48.0,
          left: MediaQuery.of(context).padding.left,
          right: MediaQuery.of(context).padding.right,
          child: Row(
            mainAxisAlignment: MainAxisAlignment.spaceAround,
            children: <Widget>[
              SimpleButton(
                onPressed: () {
                  setState(() {
                    isFlashOn = !isFlashOn;
                  });
                },
                child: Icon(
                  isFlashOn ? JustIcons.flash_on : JustIcons.flash_off,
                  color: Colors.white,
                  size: 48.0,
                  semanticLabel:
                      'Flash is ${isFlashOn ? 'on' : 'off'}. Press to toggle.',
                ),
              ),
              SimpleButton(
                onPressed: () async {
                  try {
                    await _initializeControllerFuture;

                    final String path = join(
                      (await getTemporaryDirectory()).path,
                      '${DateTime.now()}.png',
                    );

                    await _controller.takePicture(path);
                  } catch (e) {
                    print(e);
                  }
                },
                builder: (Widget child, bool isPressing) {
                  return Container(
                    width: 72.0,
                    child: AspectRatio(
                      aspectRatio: 1.0,
                      child: Stack(
                        children: <Widget>[
                          Container(
                            decoration: BoxDecoration(
                              color: const Color(0x00000000),
                              shape: BoxShape.circle,
                              border:
                                  Border.all(width: 4.0, color: Colors.white),
                            ),
                          ),
                          Center(
                            child: AnimatedContainer(
                              duration: const Duration(milliseconds: 400),
                              curve: Curves.elasticIn,
                              width: isPressing ? 48.0 : 40.0,
                              decoration: BoxDecoration(
                                color: Colors.white,
                                shape: BoxShape.circle,
                                border:
                                    Border.all(width: 4.0, color: Colors.white),
                              ),
                            ),
                          ),
                        ],
                      ),
                    ),
                  );
                },
              ),
              SimpleButton(
                onPressed: cameras.length > 1
                    ? () {
                        isRear = !isRear;
                        _controller = CameraController(
                          isRear
                              ? cameras.first
                              : cameras.length > 1 ? cameras[1] : cameras.first,
                          ResolutionPreset.max,
                        );

                        _initializeControllerFuture = _controller.initialize();

                        setState(() {});
                      }
                    : null,
                child: Icon(
                  JustIcons.refresh,
                  color: Colors.white,
                  size: 48.0,
                  semanticLabel:
                      'Flash is ${isFlashOn ? 'on' : 'off'}. Press to toggle.',
                ),
              )
            ],
          ),
        ),
      ],
    );
  }
}
