part of '../cart_checkout_page.dart';

class _DeliveryLocationPanel extends StatefulWidget {
  final LatLng initialLocation;
  final LatLng? selectedLocation;
  final ValueChanged<LatLng> onLocationSelected;

  const _DeliveryLocationPanel({
    required this.initialLocation,
    required this.selectedLocation,
    required this.onLocationSelected,
  });

  @override
  State<_DeliveryLocationPanel> createState() => _DeliveryLocationPanelState();
}
