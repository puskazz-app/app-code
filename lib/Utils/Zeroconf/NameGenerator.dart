import 'dart:math';

class NameGenerator {
  List<String> names = [
      'Adorable',
      'Beautiful',
      'Clean',
      'Drab',
      'Elegant',
      'Fancy',
      'Glamorous',
      'Handsome',
      'Long',
      'Magnificent',
      'Old-fashioned',
      'Plain',
      'Quaint',
      'Sparkling',
      'Ugliest',
      'Unsightly',
      'Wide-eyed',
      'Red',
      'Orange',
      'Yellow',
      'Green',
      'Blue',
      'Purple',
      'Gray',
      'Black',
      'White',
      'Alive',
      'Better',
      'Careful',
      'Clever',
      'Dead',
      'Easy',
      'Famous',
      'Gifted',
      'Hallowed',
      'Helpful',
      'Important',
      'Inexpensive',
      'Mealy',
      'Mushy',
      'Odd',
      'Poor',
      'Powerful',
      'Rich',
      'Shy',
      'Tender',
      'Unimportant',
      'Uninterested',
      'Vast',
      'Wrong',
      'Angry',
      'Clumsy',
      'Envious',
      'Fragile',
      'Guilt',
      'Helpless',
      'Itchy',
      'Jealous',
      'Lazy',
      'Mysterious',
      'Nervous',
      'Obnoxious',
      'Panicky',
      'Relieved',
      'Scary',
      'Thoughtless',
      'Uptight',
      'Worried',
      'Broad',
      'Chubby',
      'Crooked',
      'Curved',
      'Deep',
      'Flat',
      'High',
      'Hollow',
      'Low',
      'Narrow',
      'Refined',
      'Round',
      'Shallow',
      'Skinny',
      'Square',
      'Steep',
      'Straight',
      'Wide',
      'Big',
      'Colossal',
      'Fat',
      'Gigantic',
      'Great',
      'Huge',
      'Immense',
      'Large',
      'Little',
      'Mammoth',
      'Massive',
      'Microscopic',
      'Miniature',
      'Petite',
      'Puny',
      'Scrawny',
      'Short',
      'Small',
      'Tall',
      'Teeny',
      'Tiny',
      'Bumpy',
      'Chilly',
      'Cold',
      'Cool',
      'Cuddly',
      'Damaged',
      'Damp',
      'Dirty',
      'Dry',
      'Flaky',
      'Fluffy',
      'Freezing',
      'Greasy',
      'Hot',
      'Icy',
      'Loose',
      'Melting',
    ];
  String generatedNames() {
    
    return names[Random().nextInt(names.length)];
  }
}