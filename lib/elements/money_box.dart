// dart packages
import 'dart:convert';

// flutter packages
import 'package:flutter/material.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:shared_preferences/shared_preferences.dart';

// third-party packages

// project packages
import 'package:iou/colors.dart';


class MoneyBox extends StatefulWidget {
  const MoneyBox({
		super.key,
		required this.index,
		required this.bgColor,
		required this.name,
		required this.money,
		required this.percentage,
	});

	final index;

	final Color bgColor;
	final String name;
	final double money;
	final int percentage;

  @override
  State<MoneyBox> createState() => _MoneyBoxState();
}

class _MoneyBoxState extends State<MoneyBox> {
	bool open = false;

	TextEditingController moneyTextEditingController = TextEditingController();

	@override
	void dispose() {
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
			child: AnimatedContainer(
				duration: const Duration(milliseconds: 500),
				width: !open ? 150 : screenWidth - 49,
				decoration: BoxDecoration(
					borderRadius: BorderRadius.all(Radius.circular(30)),
					color: widget.bgColor,
				),
				child: Column(
					mainAxisAlignment: MainAxisAlignment.center,
					children: [
						Row(children: [
							Padding(padding: EdgeInsets.only(right: 20)),	
							Icon(
								Icons.payments,
								color: whiteTextColor,
							),
							Padding(padding: EdgeInsets.only(right: 10)),
							Text(
								widget.name,
								style: GoogleFonts.bebasNeue(
									fontSize: 20,
									color: whiteTextColor,
								),	
							),
							const Spacer(),
							open
								? Text(
									widget.money > 999999999
										? "\$${(widget.money / 1000000000).toStringAsFixed(1)}B"
										: widget.money > 999999
											? "\$${(widget.money / 1000000).toStringAsFixed(1)}M"
											: widget.money > 999
												? "\$${(widget.money / 1000).toStringAsFixed(1)}K"
												: "\$${(widget.money).toStringAsFixed(2)}",
									style: GoogleFonts.bebasNeue(
										fontSize: 25,
										fontWeight: FontWeight.bold,
										color: whiteTextColor,
									),	
								)
								: SizedBox(),
							Padding(padding: EdgeInsets.only(left: open ? 20 : 0)),
						]),	
						!open
						 	? Text(
								widget.money > 999999999
									? "\$${(widget.money / 1000000000).toStringAsFixed(1)}B"
									: widget.money > 999999
										? "\$${(widget.money / 1000000).toStringAsFixed(1)}M"
										: widget.money > 999
											? "\$${(widget.money / 1000).toStringAsFixed(1)}K"
											: "\$${(widget.money).toStringAsFixed(2)}",
								style: GoogleFonts.bebasNeue(
									fontSize: 45,
									fontWeight: FontWeight.bold,
									color: whiteTextColor,
								),	
							)
							: SizedBox(
									width: screenWidth - 100,
									child: TextField(
										controller: moneyTextEditingController,
										style: GoogleFonts.bebasNeue(
											color: whiteTextColor,
										),
										decoration: InputDecoration(
											hintText: "Money",
											hintStyle: GoogleFonts.bebasNeue(color: whiteTextColor),
										),
									),
								),
						Padding(padding: EdgeInsets.only(bottom: open ? 10 : 0)),	
						!open
							? Row(children: [
								const Spacer(),
								Text(
									"${widget.percentage}%",
									style: GoogleFonts.bebasNeue(
										fontWeight: FontWeight.bold,
										color: whiteTextColor,
									),	
								),
								Padding(padding: EdgeInsets.only(left: 20))
							])
							: Row(children: [
								Padding(padding: EdgeInsets.only(right: 20)),
								// Add Button
								IconButton(
									onPressed: () {
										addMoney();
									},
									icon: Icon(
										Icons.add_circle,
										color: Colors.green,
									),
								),
								const Spacer(),
								// Remove Button
								IconButton(
									onPressed: () {
										removeMoney();
									},
									icon: Icon(
										Icons.remove_circle,
										color: Colors.orange,
									),
								),
								const Spacer(),
								// Cancel Button
								IconButton(
									onPressed: () {
										setState(() {
											open = false;
										});
									},
									icon: Icon(
										Icons.cancel,
										color: Colors.deepOrange,
									),
								),
								const Spacer(),
								// Delete Button
								IconButton(
									onPressed: () {
										deletePerson();
									},
									icon: Icon(
										Icons.delete,
										color: Colors.red,
									),
								),
								Padding(padding: EdgeInsets.only(left: 20)),
							]),
					],
				),
			),
		); 
  }

	addMoney() async {
		final SharedPreferences prefs = await SharedPreferences.getInstance();
		String moneyData = prefs.getString("moneydata") ?? '{"data":[]}';
		Map moneyDataMap = jsonDecode(moneyData);	
		
		double money = moneyDataMap["data"][widget.index]["money"];
		money += double.parse(moneyTextEditingController.text);
		moneyDataMap["data"][widget.index]["money"] = money;

		await prefs.setString("moneydata", jsonEncode(moneyDataMap));

		await addTransaction(true);

		setState(() {
			moneyTextEditingController.text = "";
			open = false;
		});
	}

	removeMoney() async {
		final SharedPreferences prefs = await SharedPreferences.getInstance();
		String moneyData = prefs.getString("moneydata") ?? '{"data":[]}';
		Map moneyDataMap = jsonDecode(moneyData);	
		
		double money = moneyDataMap["data"][widget.index]["money"];
		money -= double.parse(moneyTextEditingController.text);
		moneyDataMap["data"][widget.index]["money"] = money;

		await prefs.setString("moneydata", jsonEncode(moneyDataMap));

		await addTransaction(false);

		setState(() {
			moneyTextEditingController.text = "";
			open = false;
		});
	}

	deletePerson() async {
		final SharedPreferences prefs = await SharedPreferences.getInstance();
		String moneyData = prefs.getString("moneydata") ?? '{"data":[]}';
		Map moneyDataMap = jsonDecode(moneyData);	
		
		moneyDataMap["data"].removeAt(widget.index);

		await prefs.setString("moneydata", jsonEncode(moneyDataMap));

		setState(() {
			moneyTextEditingController.text = "";
			open = false;
		});
	}

	addTransaction(bool adding) async {
		final SharedPreferences prefs = await SharedPreferences.getInstance();
		String transactionData = prefs.getString("transactiondata") ?? '{"data":[]}';
		Map transactionDataMap = jsonDecode(transactionData);
		
		transactionDataMap["data"].add({
			"name": widget.name,
			"adding": adding,
			"money": double.parse(moneyTextEditingController.text),
		});

		await prefs.setString("transactiondata", jsonEncode(transactionDataMap));
	}
}
