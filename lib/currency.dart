import 'package:intl/intl.dart';
import 'package:flutter/material.dart';
import 'package:flutter/services.dart';

class CurrencyFormat extends TextInputFormatter {
  final int maxDigits;
  CurrencyFormat({@required this.maxDigits});

  TextEditingValue formatEditUpdate(
      TextEditingValue oldValue, TextEditingValue newValue) {
    print('oldValue: ${oldValue.text}');
    print('newValue: ${newValue.text}');

    if (newValue.text.length == 0) {
      print('ini kosong');
      return newValue.copyWith(
          text: '0', selection: TextSelection.collapsed(offset: 1));
    } else {
      final f = new NumberFormat('#,###', "id");
      int numNew = int.parse(newValue.text.replaceAll(f.symbols.GROUP_SEP, ''));
      final stringNew = f.format(numNew);

      if (stringNew.length > maxDigits) {
        print('stringNew: $stringNew');
        print('melebihi digits');
        return oldValue;
      } else if (stringNew.compareTo(oldValue.text) != 0) {
        print('else jika berbeda');
        int selectionIndexFromTheRight =
            newValue.text.length - newValue.selection.end;
        print('selectionIndexFromTheRight : $selectionIndexFromTheRight');
        return new TextEditingValue(
          text: stringNew,
          selection: TextSelection.collapsed(
              offset: stringNew.length), // - selectionIndexFromTheRight),
        );
      } else {
        print('else semuanya');
        return newValue;
      }
    }
  }
}
