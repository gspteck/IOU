// dart packages

// flutter packages
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:iou/colors.dart';

// third-party packages

// project packages

class TransactionBox extends StatefulWidget {
  const TransactionBox({
		super.key,
		required this.name,
		required this.adding,
		required this.money,
	});

	final String name;
	final bool adding;
	final String money;

  @override
  State<TransactionBox> createState() => _TransactionBoxState();
}

class _TransactionBoxState extends State<TransactionBox> {
  @override
  Widget build(BuildContext context) {
		final topPaddingHeight = MediaQuery.of(context).padding.top;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenAvrg = (screenWidth/9 + screenHeight/16)/2;

		return Container(	
			height: 75,
			decoration: BoxDecoration(
				borderRadius: BorderRadius.all(Radius.circular(50)),
				color: secondaryColor,
			),
			child: Row(children: [
				Padding(padding: EdgeInsets.only(right: 20)),
				CircleAvatar(
					backgroundColor: backgroundColor,
					child: Icon(
						Icons.person,
						color: Colors.blue,
					),
				),
				Padding(padding: EdgeInsets.only(right: 20)),
				Text(
					widget.name,
					style: GoogleFonts.bebasNeue(
						fontSize: 20,
						fontWeight: FontWeight.bold,
						color: whiteTextColor,
					),
				),
				const Spacer(),
				Text(
					widget.adding ? "+\$${widget.money}" : "-\$${widget.money}",
					style: GoogleFonts.bebasNeue(
						fontSize: 25,
						fontWeight: FontWeight.bold,
						color: whiteTextColor,
					),
				),
				Padding(padding: EdgeInsets.only(left: 30)),
			]),
		);
  }
}
