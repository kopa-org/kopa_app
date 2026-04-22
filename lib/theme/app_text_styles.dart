import 'package:flutter/material.dart';

class AppTextStyles extends ThemeExtension<AppTextStyles> {
  final TextStyle productRowItemName;
  final TextStyle productRowTotal;
  final TextStyle productRowItemPrice;
  final TextStyle searchText;
  final TextStyle deliveryTimeLabel;
  final TextStyle deliveryTime;

  const AppTextStyles({
    required this.productRowItemName,
    required this.productRowTotal,
    required this.productRowItemPrice,
    required this.searchText,
    required this.deliveryTimeLabel,
    required this.deliveryTime,
  });

  @override
  AppTextStyles copyWith({
    TextStyle? productRowItemName,
    TextStyle? productRowTotal,
    TextStyle? productRowItemPrice,
    TextStyle? searchText,
    TextStyle? deliveryTimeLabel,
    TextStyle? deliveryTime,
  }) {
    return AppTextStyles(
      productRowItemName: productRowItemName ?? this.productRowItemName,
      productRowTotal: productRowTotal ?? this.productRowTotal,
      productRowItemPrice: productRowItemPrice ?? this.productRowItemPrice,
      searchText: searchText ?? this.searchText,
      deliveryTimeLabel: deliveryTimeLabel ?? this.deliveryTimeLabel,
      deliveryTime: deliveryTime ?? this.deliveryTime,
    );
  }

  @override
  AppTextStyles lerp(ThemeExtension<AppTextStyles>? other, double t) {
    if (other is! AppTextStyles) {
      return this;
    }
    return AppTextStyles(
      productRowItemName: TextStyle.lerp(productRowItemName, other.productRowItemName, t)!,
      productRowTotal: TextStyle.lerp(productRowTotal, other.productRowTotal, t)!,
      productRowItemPrice: TextStyle.lerp(productRowItemPrice, other.productRowItemPrice, t)!,
      searchText: TextStyle.lerp(searchText, other.searchText, t)!,
      deliveryTimeLabel: TextStyle.lerp(deliveryTimeLabel, other.deliveryTimeLabel, t)!,
      deliveryTime: TextStyle.lerp(deliveryTime, other.deliveryTime, t)!,
    );
  }
}
