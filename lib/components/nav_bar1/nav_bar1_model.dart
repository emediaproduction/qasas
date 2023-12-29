import '/components/miniplayer/miniplayer_widget.dart';
import '/flutter_flow/flutter_flow_util.dart';
import 'nav_bar1_widget.dart' show NavBar1Widget;
import 'package:flutter/material.dart';

class NavBar1Model extends FlutterFlowModel<NavBar1Widget> {
  ///  State fields for stateful widgets in this component.

  // Model for miniplayer component.
  late MiniplayerModel miniplayerModel;

  /// Initialization and disposal methods.

  @override
  void initState(BuildContext context) {
    miniplayerModel = createModel(context, () => MiniplayerModel());
  }

  @override
  void dispose() {
    miniplayerModel.dispose();
  }

  /// Action blocks are added here.

  /// Additional helper methods are added here.
}
