import 'dart:async';
import 'dart:convert';
import 'package:binance_plus_app/data_search.dart';
import 'package:binance_plus_app/models.dart';
import 'package:bloc_pattern/bloc_pattern.dart';
import 'package:http/http.dart' as http;
import 'package:flutter/material.dart';

class Home_Page extends StatefulWidget {

  @override
  _Home_PageState createState() => _Home_PageState();
}

class _Home_PageState extends State<Home_Page> {
  //Get the API response
  Future<List<Coin>> _getcoins() async {
    http.Response response;
    response = await http.get('https://api.binance.com/api/v3/ticker/price');

    var coins = List<Coin>();

    var coinJson = json.decode(response.body);
    for (var coinsJ in coinJson) {
      coins.add(Coin.fromJson(coinsJ));
    }

    return coins;
  }


  List<Coin> coinList = List<Coin>(); //List with direct response of API
  List<Coin> CoinSearchList = List<Coin>(); //Copy of coinList, just for the search

  @override
  void initState() {
    //Every time the app launch, this funciton was called and update the list
    _getcoins().then((value) {
      setState(() {
        coinList.replaceRange(0, coinList.length, value);
        CoinSearchList = coinList;
        print(CoinSearchList.length);
      });
    });
    super.initState();
  }

  //Function to refresh the API to get new values
  Future<void> _getRefreshCoins() {
    return _getcoins().then((value) {
      setState(() {
        coinList.replaceRange(0, coinList.length, value);
        CoinSearchList = coinList;
        print(CoinSearchList.length);
      });
    });
  }

  @override
  Widget build(BuildContext context) {
    return DefaultTabController(
      length: 2,
      child: Scaffold(
          appBar: AppBar(
            actions: <Widget>[
            ],
            centerTitle: true,
            title: Text('Coin'),
            backgroundColor: Colors.black,
            bottom: TabBar(tabs: <Widget>[
              Tab(
                text: 'Marketwatch',
              ),
              Tab(
                text: 'Onboard',
              ),
            ]),
          ),
          body: CoinSearchList.length == 0
              ? Center(child: CircularProgressIndicator())
              : FutureBuilder(
                  future: _getcoins(),
                  builder: (context, snapshot) {
                    return TabBarView(
                      children: <Widget>[
                        RefreshIndicator(
                          onRefresh: _getRefreshCoins,
                          child: ListView.builder(
                              itemCount: CoinSearchList.length + 1,
                              itemBuilder: (context, index) {
//                              var end = json.decode(snapshot.data);
//                              print(end);
                                return index == 0
                                    ? _searchbar()
                                    : _listItems(index - 1);
                              }),
                        ),
                        RefreshIndicator(
                          onRefresh: _getRefreshCoins,
                          child: StreamBuilder<Map<String, Coin>>(
                            stream:
                                BlocProvider.of<FavoriteBloc>(context).outFav,
                            initialData: {},
                            builder: (context, snapshot) {
                              return ListView(
                                children: snapshot.data.values.map((v) {
                                  return Container(
                                      padding: EdgeInsets.all(8),
                                      height: 82,
                                      margin: EdgeInsets.only(
                                          left: 15,
                                          right: 15,
                                          top: 10,
                                          bottom: 5),
                                      decoration: BoxDecoration(
                                          boxShadow: [
                                            BoxShadow(
                                                color: Colors.blueAccent,
                                                offset: Offset(2, 1),
                                                blurRadius: 2)
                                          ],
                                          border: Border.all(
                                              color: Colors.black, width: 0.1),
                                          color: Colors.grey[200]),
                                      child: Column(
                                          crossAxisAlignment:
                                              CrossAxisAlignment.start,
                                          children: <Widget>[
                                            Text(v.symbol),
                                            Row(
                                              mainAxisAlignment:
                                                  MainAxisAlignment
                                                      .spaceBetween,
                                              children: <Widget>[
                                                //This is how i update the price in Onboard tab, probally has a better solution
                                                Text('Current price: ${coinList.map((value){

                                                    if(value.symbol == v.symbol){
                                                      return value.price;
                                                    }

                                                })}'.replaceAll(RegExp(r'null, '),'')),
                                                IconButton(
                                                  icon: Icon(Icons.delete),
                                                  onPressed: () {
                                                    BlocProvider.of<
                                                                FavoriteBloc>(
                                                            context)
                                                        .toggleFavorite(v);
                                                  },
                                                )
                                              ],
                                            )
                                          ]
                                      )
                                  );
                                }).toList(),
                              );
                            },
                          ),
                        ),
                      ],
                    );
                  })),
    );
  }

  _searchbar() {
    return Padding(
      padding: EdgeInsets.all(8),
      child: TextField(
        decoration: InputDecoration(hintText: 'Search for the coins'),
        onChanged: (text) {
          text = text.toLowerCase();
          setState(() {
            CoinSearchList = coinList.where((res) {
              var coin = res.symbol.toLowerCase();
              return coin.contains(text);
            }).toList();
          });
        },
      ),
    );
  }

  _listItems(index) {
    return Container(
      padding: EdgeInsets.all(8),
      height: 82,
      margin: EdgeInsets.only(left: 15, right: 15, top: 10, bottom: 5),
      decoration: BoxDecoration(
          boxShadow: [
            BoxShadow(
                color: Colors.blueAccent, offset: Offset(2, 1), blurRadius: 2)
          ],
          border: Border.all(color: Colors.black, width: 0.1),
          color: Colors.grey[200]),
      child: StreamBuilder<Map<String, Coin>>(
          stream: BlocProvider.of<FavoriteBloc>(context).outFav,
          builder: (context, snapshot) {
            if (snapshot.hasData)
              return Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: <Widget>[
                  Text(CoinSearchList[index].symbol),
                  Row(
                    mainAxisAlignment: MainAxisAlignment.spaceBetween,
                    children: <Widget>[
                      Text('Current price: ${CoinSearchList[index].price}'),
                      IconButton(
                        icon: Icon(
                            snapshot.data.containsKey(coinList[index].symbol)
                                ? Icons.favorite
                                : Icons.favorite_border),
                        onPressed: () {
                          BlocProvider.of<FavoriteBloc>(context)
                              .toggleFavorite(coinList[index]);
                        },
                      )
                    ],
                  )
                ],
              );
            else
              return CircularProgressIndicator();
          }),
    );
  }
}
