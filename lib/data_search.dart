class Coin {
  final String symbol;
  final String price;

  Coin({this.symbol,this.price});


  factory Coin.fromJson(Map<String, dynamic> json){
    if(json.containsKey('symbol'))
      return Coin(
        symbol: json['symbol'],
        price: json['price']
      );
    else
      return Coin(
        symbol: json['symbol'],
            price: json['price']
      );
  }
  Map<String, dynamic> toJson(){
    return{
      "symbol":symbol,
      "price":price
    };
  }
}