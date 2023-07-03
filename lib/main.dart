import 'package:english_words/english_words.dart';
import 'package:flutter/material.dart';
import 'package:provider/provider.dart';

void main() {
  runApp(MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

  @override
  Widget build(BuildContext context) {
    return ChangeNotifierProvider(
      create: (context) => MyAppState(),
      child: MaterialApp(
        title: 'Namer App',
        theme: ThemeData(
          useMaterial3: true,
          colorScheme: ColorScheme.fromSeed(seedColor: Colors.lightBlue),
        ),
        home: MyHomePage(),
      ),
    );
  }
}

class MyAppState extends ChangeNotifier {
  var current = WordPair.random();

  void getNext() {
    current = WordPair.random();
    notifyListeners();
  }

  // The original implementation included a List of favorites
  // Denoted by '[]', in our implementation, we include a set
  // Denoted by '{}'
  var favorites = <WordPair>{};

  void toggleFavorite() {
    if (favorites.contains(current)) {
      favorites.remove(current);
    } else {
      favorites.add(current);
    }
    notifyListeners();
  }
}

class MyHomePage extends StatefulWidget {
  @override
  State<MyHomePage> createState() => _MyHomePageState();
}

// The _ in _MyHomePageState indicates that it is a private class
class _MyHomePageState extends State<MyHomePage> {
  var selectedIndex = 0;

  @override
  Widget build(BuildContext context) {
    Widget page;
    switch (selectedIndex) {
      case 0:
        page = GeneratorPage();
        break;
      case 1:
        page = FavoritesPage();
        break;
      default:
        throw UnimplementedError('Not implemented yet');
      // or use a Placeholder() widget for the page
    }
    return LayoutBuilder(builder: (context, constraints) {
      return Scaffold(
        body: Row(
          children: [
            // Widget that avoids OS interfaces (EX: always is on the left)
            SafeArea(
              // Navigation rail that lets us choose an array of destinations
              child: NavigationRail(
                // If enabled, extended would display the labels alongside the icons
                // We set it so it is dynamically set to true or false depending on the screen size
                extended: constraints.maxWidth >= 600,
                destinations: [
                  NavigationRailDestination(
                    icon: Icon(Icons.home),
                    label: Text('Home'),
                  ),
                  NavigationRailDestination(
                    icon: Icon(Icons.favorite),
                    label: Text('Favorites'),
                  ),
                ],
                // Default selected index (can only be 0 or 1 because we only have two indices)
                selectedIndex: selectedIndex,
                onDestinationSelected: (value) {
                  print('selected: $value');

                  setState(() {
                    selectedIndex = value;
                  });
                },
              ),
            ),
            // Second section of the row, the actual destination that we have set
            Expanded(
              child: Container(
                color: Theme.of(context).colorScheme.primaryContainer,
                child: page,
              ),
            ),
          ],
        ),
      );
    });
  }
}

class FavoritesPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var myFavs = appState.favorites;

    return ListView(
      children: [
        Padding(
          padding: const EdgeInsets.all(20),
          child: Text('You have '
              '${myFavs.length} favorites:'),
        ),
        for (var pair in myFavs)
          ListTile(
            leading: Icon(Icons.favorite_border_rounded),
            title: Text(pair.asPascalCase),
          ),
      ],
    );
  }
}

class GeneratorPage extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    var appState = context.watch<MyAppState>();
    var currentWord = appState.current;

    IconData icon;
    if (appState.favorites.contains(currentWord)) {
      icon = Icons.favorite;
    } else {
      icon = Icons.favorite_border;
    }

    return Center(
      child: Column(
        // This centers the children inside the Column along its
        // main vertical axis
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          BigCard(currentWord: currentWord),
          // A separator box
          SizedBox(height: 10),
          Row(
            // Makes sure the row doesn't take up the whole screen
            mainAxisSize: MainAxisSize.min,
            children: [
              // We must use the .icon to use a button with an icon in it
              ElevatedButton.icon(
                onPressed: () {
                  appState.toggleFavorite();
                },
                icon: Icon(icon),
                label: Text('Like'),
              ),
              // Separator
              SizedBox(width: 20),
              ElevatedButton(
                onPressed: () {
                  appState.getNext();
                },
                child: Text('Next'),
              ),
            ],
          ),
        ],
      ),
    );
  }
}

class BigCard extends StatelessWidget {
  const BigCard({
    super.key,
    required this.currentWord,
  });

  final WordPair currentWord;

  @override
  Widget build(BuildContext context) {
    // Background Color Theme (used in the color of the card)
    final theme = Theme.of(context);

    // Text Theme
    // displayMedium is the size
    // Claling copyWith() on displayMedium returns a copy of the
    // text style with the changes you define (IE the text color)
    final style = theme.textTheme.displayMedium!.copyWith(
      color: theme.colorScheme.onPrimary,
    );

    return Card(
      color: theme.colorScheme.primary,
      child: Padding(
        padding: const EdgeInsets.all(40),
        // we apply the style we set up at the start here
        child: Text(currentWord.asPascalCase,
            style: style,
            // This is done to make sure any software reading it understands how to read
            // the two words
            semanticsLabel: "${currentWord.first} ${currentWord.second}"),
      ),
    );
  }
}
