import '/components/nav_bar/nav_bar_widget.dart';
import '/flutter_flow/flutter_flow_theme.dart';
import '/flutter_flow/flutter_flow_util.dart';
import '/flutter_flow/flutter_flow_widgets.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'home_page_model.dart';
export 'home_page_model.dart';
import 'package:shared_preferences/shared_preferences.dart';
import 'package:image_picker/image_picker.dart';
import 'dart:io';
import 'package:tflite_v2/tflite_v2.dart';
import 'package:percent_indicator/percent_indicator.dart';
import 'package:gallery_saver/gallery_saver.dart';
import 'package:face_cropper/face_cropper.dart';


class HomePageWidget extends StatefulWidget {

  const HomePageWidget({super.key});

  @override
  State<HomePageWidget> createState() => _HomePageWidgetState();
}

class _HomePageWidgetState extends State<HomePageWidget> {

  //XFile? _image;
  File? file;
  List? _recognitions;
  bool isLoading = false;
  bool _isImageSelected = false;
  String? _imagePath;
  String? _croppedImagePath;
  FaceCropper faceCropper = FaceCropper();
  bool _isLoading = false;

  late HomePageModel _model;

  final scaffoldKey = GlobalKey<ScaffoldState>();

  @override
  void initState() {
    super.initState();
    _model = createModel(context, () => HomePageModel());
    _loadThemePreference();
    _loadModel();
  }

  @override
  void dispose() {
    _model.dispose();
    super.dispose();
  }

  Future<void> _loadThemePreference() async {
    final prefs = await SharedPreferences.getInstance();
    final isDarkTheme = prefs.getBool('isDarkTheme') ?? false;

    setDarkModeSetting(context, isDarkTheme ? ThemeMode.dark : ThemeMode.light);

    SystemChrome.setSystemUIOverlayStyle(
      SystemUiOverlayStyle(
        statusBarColor: Colors.transparent,
        statusBarIconBrightness: Brightness.dark,
        statusBarBrightness: Brightness.light,
        systemNavigationBarColor: FlutterFlowTheme.of(context).secondaryBackground,
        systemNavigationBarIconBrightness: isDarkTheme ? Brightness.light : Brightness.dark,
      ),
    );
  }

  Future<void> _selectImageGallery() async {
    final image = await ImagePicker().pickImage(source: ImageSource.gallery);
    if (image != null) {
      setState(() {
        //_image = image;
        file = File(image.path);
        _detectImage(file!);
        _isImageSelected = true;
      });
    }
  }

  Future<void> _loadModel() async {
    await Tflite.loadModel(
      model: "assets/model/model_unquant.tflite",
      labels: "assets/model/labels.txt",
    );
  }

  Future<void> _detectImage(File image) async {
    var recognitions = await Tflite.runModelOnImage(
        path: image.path,   // required
        imageMean: 0.0,     // defaults to 117.0
        imageStd: 255.0,    // defaults to 1.0
        numResults: 1,      // defaults to 5
        threshold: 0.0,     // defaults to 0.1
        asynch: true        // defaults to true
    );

    setState(() {
      _recognitions = recognitions;
    });
  }

  Future<void> _selectImageCamera() async {
    setState(() {
      _isLoading = true;
    });

    try {
      final image = await ImagePicker().pickImage(source: ImageSource.camera);

      if (image == null) {
        print("No image captured.");
        setState(() {
          _isLoading = false;
        });
        return;
      }

      await GallerySaver.saveImage(image.path);
      _imagePath = image.path;

      final croppedImage = await faceCropper.detectFacesAndCrop(_imagePath!);

      if (croppedImage != null) {
        setState(() {
          _croppedImagePath = croppedImage;
        });

        await GallerySaver.saveImage(croppedImage);
        final galleryImage = await ImagePicker().pickImage(source: ImageSource.gallery);

        if(galleryImage != null)
        {
          file = File(galleryImage.path);
          _detectImage(file!);
          _isImageSelected = true;
        }
      }
    } catch (e) {
      print("Error: $e");
    } finally {
      setState(() {
        _isLoading = false;
      });
    }
  }

  @override
  Widget build(BuildContext context) {
    if (_isLoading) {
      return Container(
        decoration: BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFA7BFE8), Color(0xFF6190E8)],
            stops: [0.0, 1.0],
            begin: AlignmentDirectional(0.0, -1.0),
            end: AlignmentDirectional(0, 1.0),
          ),
        ),
        child: Center(
          child: CircularProgressIndicator(
            valueColor: AlwaysStoppedAnimation<Color>(FlutterFlowTheme.of(context).secondaryBackground),
          ),
        ),
      );
    }

    return _isImageSelected ? buildPart2(context) : buildPart1(context);
  }

  Widget buildPart1(BuildContext context) {
    return Scaffold(
      key: scaffoldKey,
      body: Container(
        decoration: const BoxDecoration(
          gradient: LinearGradient(
            colors: [Color(0xFFA7BFE8), Color(0xFF6190E8)],
            stops: [0.0, 1.0],
            begin: AlignmentDirectional(0.0, -1.0),
            end: AlignmentDirectional(0, 1.0),
          ),
        ),
        child: Stack(
          children: [
            Align(
              alignment: const AlignmentDirectional(0.0, 1.0),
              child: wrapWithModel(
                model: _model.navBarModel,
                updateCallback: () => safeSetState(() {}),
                child: const NavBarWidget(
                  index: 1,
                  hidden: false,
                ),
              ),
            ),
            Align(
              alignment: const AlignmentDirectional(0.0, 1.0),
              child: Column(
                mainAxisSize: MainAxisSize.max,
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  Align(
                    alignment: const AlignmentDirectional(0.0, 1.0),
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(30.0, 100.0, 30.0, 0.0),
                      child: FFButtonWidget(
                        onPressed: () {
                          _selectImageCamera();
                        },
                        text: 'Take Photo',
                        options: FFButtonOptions(
                          width: double.infinity,
                          height: 50.0,
                          padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                          iconAlignment: IconAlignment.start,
                          iconPadding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                          color: FlutterFlowTheme.of(context).secondaryBackground,
                          textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                            fontFamily: 'Inter Tight',
                            color: FlutterFlowTheme.of(context).primaryText,
                            letterSpacing: 0.0,
                          ),
                          elevation: 0.0,
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        showLoadingIndicator: false,
                      ),
                    ),
                  ),
                  Align(
                    alignment: const AlignmentDirectional(0.0, 1.0),
                    child: Padding(
                      padding: const EdgeInsetsDirectional.fromSTEB(30.0, 0.0, 30.0, 0.0),
                      child: FFButtonWidget(
                        onPressed: () {
                          _selectImageGallery();
                        },
                        text: 'Gallery',
                        options: FFButtonOptions(
                          width: double.infinity,
                          height: 50.0,
                          padding: const EdgeInsetsDirectional.fromSTEB(16.0, 0.0, 16.0, 0.0),
                          iconAlignment: IconAlignment.start,
                          iconPadding: const EdgeInsetsDirectional.fromSTEB(0.0, 0.0, 0.0, 0.0),
                          color: FlutterFlowTheme.of(context).secondaryBackground,
                          textStyle: FlutterFlowTheme.of(context).titleSmall.override(
                            fontFamily: 'Inter Tight',
                            color: FlutterFlowTheme.of(context).primaryText,
                            letterSpacing: 0.0,
                          ),
                          elevation: 0.0,
                          borderRadius: BorderRadius.circular(15.0),
                        ),
                        showLoadingIndicator: false,
                      ),
                    ),
                  ),
                ].divide(const SizedBox(height: 40.0)).addToStart(const SizedBox(height: 200.0)),
              ),
            ),
            Column(
              mainAxisSize: MainAxisSize.max,
              mainAxisAlignment: MainAxisAlignment.center,
              children: [
                Padding(
                  padding: const EdgeInsetsDirectional.fromSTEB(0.0, 80.0, 0.0, 20.0),
                  child: Container(
                    width: 220.0,
                    height: 220.0,
                    decoration: BoxDecoration(
                      shape: BoxShape.circle,
                      border: Border.all(
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        width: 6.0,
                      ),
                    ),
                    child: ClipRRect(
                      borderRadius: BorderRadius.circular(100.0),
                      child: Image.asset(
                        'assets/images/face.png',
                        width: 200.0,
                        height: 200.0,
                        fit: BoxFit.contain,
                        alignment: const Alignment(0.0, 0.0),
                      ),
                    ),
                  ),
                ),
                Align(
                  alignment: const AlignmentDirectional(0.0, 0.0),
                  child: Padding(
                    padding: const EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 200.0),
                    child: Text(
                      'Please provide a close-up image',
                      textAlign: TextAlign.center,
                      style: FlutterFlowTheme.of(context).bodyMedium.override(
                        fontFamily: 'Inter',
                        color: FlutterFlowTheme.of(context).secondaryBackground,
                        fontSize: 20.0,
                        letterSpacing: 0.0,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                  ),
                ),
              ].divide(const SizedBox(height: 12.0)).addToEnd(const SizedBox(height: 100.0)),
            ),
          ],
        ),
      ),
    );
  }

  @override
  Widget buildPart2(BuildContext context) {

    String label;
    double confidence;
    print(_recognitions);
    if (_recognitions != null && _recognitions!.isNotEmpty)
    {
      confidence = _recognitions![0]['confidence'] * 100;

      if (confidence >= 50)
      {
        label = 'Healthy';
      }
      else
      {
        label = 'Down Syndrome';
        confidence = (100 - confidence);
      }
    }
    else
    {
      label = ' ';
      confidence = 0;
    }

    print(confidence);
    String confidenceDisplay = '${confidence.toInt()}%';

    return WillPopScope(
      onWillPop: () async {
        setState(() {
          _isImageSelected = false;
        });
        return false;
      },
      child: Scaffold(
        key: scaffoldKey,
        body: Container(
          decoration: const BoxDecoration(
            gradient: LinearGradient(
              colors: [Color(0xFFA7BFE8), Color(0xFF6190E8)],
              stops: [0.0, 1.0],
              begin: AlignmentDirectional(0.0, -1.0),
              end: AlignmentDirectional(0, 1.0),
            ),
          ),
          child: Stack(
            children: [
              Align(
                alignment: const AlignmentDirectional(0.0, 1.0),
                child: wrapWithModel(
                  model: _model.navBarModel,
                  updateCallback: () => safeSetState(() {}),
                  child: const NavBarWidget(
                    index: 1,
                    hidden: false,
                  ),
                ),
              ),
              Align(
                alignment: const AlignmentDirectional(0.0, 0.0),
                child: Column(
                  mainAxisSize: MainAxisSize.max,
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Padding(
                      padding:
                      const EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 0.0),
                      child: Container(
                        width: double.infinity,
                        height: 350.0,
                        decoration: BoxDecoration(
                          color: FlutterFlowTheme.of(context).secondaryBackground,
                          borderRadius: BorderRadius.circular(20.0),
                        ),
                        child: Padding(
                          padding: const EdgeInsets.all(10.0),
                          child: ClipRRect(
                            borderRadius: BorderRadius.circular(20.0),
                            child: file != null && file!.existsSync()
                                ? Image.file(
                              file!,
                              width: 500.0,
                              height: 500.0,
                              fit: BoxFit.cover,
                            )
                                : Center(child: Text('No image found.')),
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: const AlignmentDirectional(0.0, 0.0),
                      child: Padding(
                        padding:
                        const EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 0.0),
                        child: Container(
                          width: double.infinity,
                          height: 120.0,
                          decoration: BoxDecoration(
                            color:
                            FlutterFlowTheme.of(context).secondaryBackground,
                            borderRadius: BorderRadius.circular(20.0),
                          ),
                          child: Align(
                            alignment: const AlignmentDirectional(0.0, 0.0),
                            child: Column(
                              mainAxisSize: MainAxisSize.max,
                              mainAxisAlignment: MainAxisAlignment.center,
                              children: [
                                Align(
                                  alignment: const AlignmentDirectional(0.0, 0.0),
                                  child: Text(
                                    label,
                                    textAlign: TextAlign.center,
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                      fontFamily: 'Inter',
                                      fontSize: 22.0,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                Align(
                                  alignment: const AlignmentDirectional(0.0, 0.0),
                                  child: Text(
                                    confidenceDisplay,
                                    textAlign: TextAlign.center,
                                    style: FlutterFlowTheme.of(context)
                                        .bodyMedium
                                        .override(
                                      fontFamily: 'Inter',
                                      fontSize: 24.0,
                                      letterSpacing: 0.0,
                                      fontWeight: FontWeight.w800,
                                    ),
                                  ),
                                ),
                                Padding(
                                  padding: const EdgeInsetsDirectional.fromSTEB(
                                      30.0, 0.0, 30.0, 0.0),
                                  child: LinearPercentIndicator(
                                    percent: confidence / 100,
                                    lineHeight: 12.0,
                                    animation: true,
                                    animateFromLastPercent: false,
                                    progressColor:
                                    FlutterFlowTheme.of(context).primaryText,
                                    backgroundColor:
                                    FlutterFlowTheme.of(context).alternate,
                                    barRadius: const Radius.circular(20.0),
                                    padding: EdgeInsets.zero,
                                  ),
                                ),
                              ].divide(const SizedBox(height: 10.0)),
                            ),
                          ),
                        ),
                      ),
                    ),
                    Align(
                      alignment: const AlignmentDirectional(0.0, 1.0),
                      child: Padding(
                        padding:
                        const EdgeInsetsDirectional.fromSTEB(20.0, 0.0, 20.0, 0.0),
                        child: Text(
                          'This is an experimental build and it may make mistakes',
                          textAlign: TextAlign.center,
                          style: FlutterFlowTheme.of(context).bodyMedium.override(
                            fontFamily: 'Inter',
                            fontSize: 12.0,
                            letterSpacing: 0.0,
                          ),
                        ),
                      ),
                    ),
                  ].divide(const SizedBox(height: 14.0)),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}