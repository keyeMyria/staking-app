
import 'package:flutter/material.dart';
import 'package:sms/sms.dart';
import 'dart:io';

class SmsListener {
  final String from;
  final Function formatBody;

  SmsListener({@required this.from, this.formatBody});
}

class PinView extends StatefulWidget {
  final Function submit;
  final int count;
  final bool obscureText;
  final bool autoFocusFirstField;
  final bool enabled;
  final List<int> dashPositions;
  final SmsListener sms;
  final TextStyle style;
  final TextStyle dashStyle;
  final InputDecoration inputDecoration;
  final EdgeInsetsGeometry margin;
  final String splicingSymbol;

  PinView(
      {
        Key key,
        @required this.submit,
      @required this.count,
      this.obscureText: false,
      this.autoFocusFirstField: true,
      this.enabled: true,
      this.dashPositions: const [],
      this.sms,
      this.dashStyle: const TextStyle(fontSize: 30.0, color: Colors.grey),
      this.style: const TextStyle(
        fontSize: 20.0,
        fontWeight: FontWeight.w500,
      ),
      this.splicingSymbol = '-',
      this.inputDecoration:
          const InputDecoration(border: UnderlineInputBorder()),
      this.margin: const EdgeInsets.all(5.0)}) : super(key: key);

  @override
  PinViewState createState() => PinViewState();
}

class PinViewState extends State<PinView> {
  List<TextEditingController> _controllers;
  List<FocusNode> _focusNodes;
  List<String> _pin;
  SmsReceiver _smsReceiver;
  bool isInitBuild = true;
  @override
  void initState() {
    super.initState();
    if (widget.sms != null) {
      _listenSms();
    }
    _pin = List<String>.generate(widget.count, (int index) => "");
    _focusNodes =
        List.generate(widget.count, (int index) => FocusNode()).toList();
    _controllers =
        List.generate(widget.count, (int index) => TextEditingController.fromValue(TextEditingValue(
          // 设置内容
            text: _pin[index],
            // 保持光标在最后
            selection: TextSelection.fromPosition(TextPosition(
                affinity: TextAffinity.downstream,
                offset: _pin[index].length)))));
  }

  void _listenSms() async {
    _smsReceiver = SmsReceiver();
    _smsReceiver.onSmsReceived.listen((SmsMessage message) {
      if (message.sender == widget.sms.from) {
        String code = widget.sms.formatBody != null
            ? widget.sms.formatBody(message.body)
            : message.body;
        for (TextEditingController controller in _controllers) {
          controller.text = code[_controllers.indexOf(controller)];
          _pin[_controllers.indexOf(controller)] = controller.text;
        }

        widget.submit(_pin.join());
      }
    });
  }

  Widget _dash() {
    return Flexible(flex: 1, child: Text(widget.splicingSymbol, style: widget.dashStyle));
  }
  void hideKeyboard(){
    for(int i=0; i<_focusNodes.length; i++ ){
      _focusNodes[i].unfocus();
    }
  }

  @override
  Widget build(BuildContext context) {
    List<Widget> pins = List<Widget>.generate(
        widget.count, (int index) => _singlePinView(index)).toList();

    for (int i in widget.dashPositions) {
      if (i <= widget.count) {
        List<int> smaller =
            widget.dashPositions.where((int d) => d < i).toList();
        pins.insert(i + smaller.length, _dash());
      }
    }
    if(isInitBuild) {
      for(int i=0; i<_controllers.length; i++){
          _controllers[i].text = " ";
      }
      setState(() {
        isInitBuild = false;
      });
    }

    return Container(
      child: Row(
          crossAxisAlignment: CrossAxisAlignment.center,
          mainAxisAlignment: MainAxisAlignment.spaceAround,
          children: pins),
    );
  }

  Widget _singlePinView(int index) {
    return Flexible(
        flex: 3,
        child: Container(
            margin: widget.margin,
            child: TextField(
              enabled: widget.enabled,
              controller: _controllers[index],
              obscureText: widget.obscureText,
              autofocus: widget.autoFocusFirstField ? index == 0 : false,
              focusNode: _focusNodes[index],
              keyboardType: TextInputType.number,
              textAlign: TextAlign.center,
              style: widget.style,
              decoration: widget.inputDecoration,
              textInputAction: TextInputAction.next,
              onChanged: (String val) {
                if (val.length == 1) {
                  if(Platform.isIOS){
                    _controllers[index].text = " ";
                  }
                  val = val.trim();
                  _pin[index] = '';
                  if (index != 0) {
//                    _focusNodes[index].unfocus();
//                    FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
                  }
                } else if (val.length == 2) {
                  val = val.trim();
                  _controllers[index].text = " " + val.substring(val.length-1, val.length);
                  _pin[index] = val;
                  if (index != _focusNodes.length - 1) {
                    _focusNodes[index].unfocus();
                    FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
                  }

                } else if(val.length == 3){
                  val = val.trim();
                  _controllers[index].text = " " + val.substring(val.length-1, val.length);
                  _pin[index] = val.substring(val.length-1, val.length);
                  if (index != _focusNodes.length - 1) {
                    _focusNodes[index].unfocus();
                    FocusScope.of(context).requestFocus(_focusNodes[index + 1]);
                  }
                }else {
                  _controllers[index].text = " ";
                  _pin[index] = "";
                  if (index != 0) {
                   _controllers[index-1].text = " ";
                    _focusNodes[index].unfocus();
                    FocusScope.of(context).requestFocus(_focusNodes[index - 1]);
                  }
                }

                  widget.submit(_pin.join().trim());
                if(_pin.join().trim().length >=4) {
                  _focusNodes[index].unfocus();
                }
              },
            )));
  }
}
