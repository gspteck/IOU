// dart packages
import 'dart:math';
import 'dart:convert';
import 'dart:ui';

// flutter packages
import 'package:flutter/material.dart';

// third-party packages
import 'package:google_fonts/google_fonts.dart';
import 'package:dotted_border/dotted_border.dart';
import 'package:shared_preferences/shared_preferences.dart';

// project packages
import 'package:iou/colors.dart';

import 'package:iou/main.dart';
import 'package:iou/services/appodeal.dart';
import 'package:iou/services/firebase.dart';

// currencySymbol + t() are already exported from main.dart


class AddButton extends StatefulWidget {
  const AddButton({super.key});

  @override
  State<AddButton> createState() => _AddButtonState();
}

class _AddButtonState extends State<AddButton> {
	bool open = false;

	TextEditingController nameTextEditingController = TextEditingController();
	TextEditingController moneyTextEditingController = TextEditingController();

	@override
		void dispose() {
			nameTextEditingController.dispose();
			moneyTextEditingController.dispose();
			super.dispose();
		}

  @override
  Widget build(BuildContext context) {
		final topPaddingHeight = MediaQuery.of(context).padding.top;
    final screenHeight = MediaQuery.of(context).size.height;
    final screenWidth = MediaQuery.of(context).size.width;
    final screenAvrg = (screenWidth/9 + screenHeight/16)/2;

		return GestureDetector(
			onTap: () {
				if (!open) {
					setState(() {
						open = true;
					});
				} 
			},
			child: DottedBorder(
				options: RoundedRectDottedBorderOptions(
          radius: const Radius.circular(50),
          color: lightTextColor,
          strokeWidth: 2,
          dashPattern: const [5, 5],
        ),	
				child: AnimatedContainer(
					duration: const Duration(milliseconds: 500),
					width: !open ? 75 : screenWidth - 49,
					height: 200,
					decoration: BoxDecoration(
						borderRadius: BorderRadius.all(Radius.circular(50)),
						color: secondaryColor,
					),
					child: Center(
						child: !open
							? Text(
								"+",
								style: GoogleFonts.bebasNeue(
									fontSize: 50,
									color: whiteTextColor,
								),
							)
							: Column(children: [
								Padding(padding: EdgeInsets.only(bottom: 20)),
								// Name TextField
								SizedBox(
									width: screenWidth - 100,
									child: TextField(
										controller: nameTextEditingController,
										style: GoogleFonts.bebasNeue(
											color: whiteTextColor,
										),
										decoration: InputDecoration(
											hintText: t('nameHint'),
											hintStyle: GoogleFonts.bebasNeue(color: whiteTextColor),
										),
									),
								),
								// Money TextField
								SizedBox(
									width: screenWidth - 100,
									child: TextField(
										controller: moneyTextEditingController,
										keyboardType: TextInputType.number,
										style: GoogleFonts.bebasNeue(
											color:whiteTextColor,
										),
										decoration: InputDecoration(
											hintText: t('moneyHint'),
											hintStyle: GoogleFonts.bebasNeue(color: whiteTextColor),
										),
									),
								),	
								const Spacer(),
								Row(children: [
									Padding(padding: EdgeInsets.only(right: 50)),
									GestureDetector(
										onTap: () {
											setState(() {
												open = false;
											});
										},
										child: Text(
											t('cancel'),
											style: GoogleFonts.bebasNeue(
												fontSize: 20,
												color: whiteTextColor,
											),	
										),
									),
									const Spacer(),
									GestureDetector(
										onTap: () {
											addPerson();
											setState(() {
												open = false;
											});
										},
										child: Text(
											t('add'),
											style: GoogleFonts.bebasNeue(
												fontSize: 20,
												color: whiteTextColor,
											),	
										),
									),
									Padding(padding: EdgeInsets.only(left: 50)),
								]),
								Padding(padding: EdgeInsets.only(top: 20)),
							]),
					),
				),
			),
		);
  }

	addPerson() async {
  	final SharedPreferences prefs = await SharedPreferences.getInstance();

		// Get Old Money Data
		String oldData = prefs.getString("moneydata") ?? '{"data":[]}';
		Map oldDataMap = jsonDecode(oldData);

		var rng = Random();
		Map newPerson = {
			"name": nameTextEditingController.text,
			"money": double.parse(moneyTextEditingController.text),
			"colorIndex": rng.nextInt(moneyBoxColors.length),
		};

		// Add New Data
		oldDataMap["data"].add(newPerson);

		await prefs.setString("moneydata", jsonEncode(oldDataMap));

		// Also persist to Firebase when logged in
		if (userID != null && userID!.isNotEmpty) {
			try {
				final fs = FirebaseServices();
				final latestMoneyStr = prefs.getString("moneydata") ?? '{"data":[]}';
				final latestTxStr = prefs.getString("transactiondata") ?? '{"data":[]}';
				final latestUser = prefs.getString("username");
				Map<String, dynamic>? m;
				Map<String, dynamic>? t;
				try { m = jsonDecode(latestMoneyStr) as Map<String, dynamic>; } catch (_) {}
				try { t = jsonDecode(latestTxStr) as Map<String, dynamic>; } catch (_) {}
				await fs.saveIOUData(username: latestUser, moneyData: m, transactionData: t);
			} catch (_) {}
		}

		setState(() {
			nameTextEditingController.text = "";
			moneyTextEditingController.text = "";
		});

		await AppodealServices().recordAction();
	}
}
