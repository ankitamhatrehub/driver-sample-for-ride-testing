/// Dim dark Google Maps style for the home map. Based on the standard dark
/// style, softened to charcoal so it is dark without being pitch black, with
/// buildings, roads, labels, parks and water all still clearly visible.
const String homeDarkMapStyle = '''
[
  {"elementType":"geometry","stylers":[{"color":"#2b2e36"}]},
  {"elementType":"labels.text.fill","stylers":[{"color":"#a9adb8"}]},
  {"elementType":"labels.text.stroke","stylers":[{"color":"#2b2e36"}]},
  {"featureType":"administrative","elementType":"geometry","stylers":[{"color":"#4a4e59"}]},
  {"featureType":"administrative.locality","elementType":"labels.text.fill","stylers":[{"color":"#c3c6d0"}]},
  {"featureType":"landscape.man_made","elementType":"geometry","stylers":[{"color":"#363a44"}]},
  {"featureType":"landscape.man_made","elementType":"geometry.stroke","stylers":[{"color":"#454a56"}]},
  {"featureType":"landscape.natural","elementType":"geometry","stylers":[{"color":"#2b2e36"}]},
  {"featureType":"poi","elementType":"geometry","stylers":[{"color":"#343842"}]},
  {"featureType":"poi","elementType":"labels.text.fill","stylers":[{"color":"#9a9eaa"}]},
  {"featureType":"poi.park","elementType":"geometry","stylers":[{"color":"#2f3f38"}]},
  {"featureType":"poi.park","elementType":"labels.text.fill","stylers":[{"color":"#7fa592"}]},
  {"featureType":"road","elementType":"geometry","stylers":[{"color":"#454953"}]},
  {"featureType":"road","elementType":"geometry.stroke","stylers":[{"color":"#2b2e36"}]},
  {"featureType":"road","elementType":"labels.text.fill","stylers":[{"color":"#b4b8c3"}]},
  {"featureType":"road.highway","elementType":"geometry","stylers":[{"color":"#5a5f6b"}]},
  {"featureType":"road.highway","elementType":"geometry.stroke","stylers":[{"color":"#2b2e36"}]},
  {"featureType":"road.highway","elementType":"labels.text.fill","stylers":[{"color":"#d0d3dc"}]},
  {"featureType":"transit","elementType":"geometry","stylers":[{"color":"#3a3e48"}]},
  {"featureType":"transit.station","elementType":"labels.text.fill","stylers":[{"color":"#9a9eaa"}]},
  {"featureType":"water","elementType":"geometry","stylers":[{"color":"#1d2a3a"}]},
  {"featureType":"water","elementType":"labels.text.fill","stylers":[{"color":"#6f8aa8"}]}
]
''';
