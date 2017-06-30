import Foundation

class SCWordBank {
    enum Category: Int {
        case animals = 0
        case architecture = 1
        case arts = 2
        case body = 3
        case clothing = 4
        case foodAndDrinks = 5
        case game = 6
        case garden = 7
        case items = 8
        case nature = 9
        case people = 10
        case places = 11
        case space = 12
        case sports = 13
        case transportation = 14
        case misc = 15
    }

    fileprivate static let bank: [Category: [String]] = [
        .animals: [
            "Alligator", "Bark", "Bear", "Beaver", "Bee", "Bird", "Buffalo", "Bug", "Bunny", "Cat", "Chick", "Chicken", "Cow", "Crow", "Dinosaur", "Dog", "Dragon", "Duck", "Eagle", "Elephant", "Fish", "Flock", "Fly", "Frog", "Gallop", "Goose", "Hawk", "Horse", "Ivory", "Kangaroo", "Koala", "Ladybug", "Lion", "Lizard", "Mammoth", "Mate", "Monster", "Moose", "Moth", "Mouse", "Nest", "Octopus", "Penguin", "Platypus", "Puppy", "Rabbit", "Salmon", "Scorpion", "Seal", "Shark", "Sheep", "Spider", "Tail", "Tiger", "Unicorn", "Wasp", "Whale", "Wolf", "Wool", "Worm", "Zoo"
        ],
        .architecture: [
            "Bank", "Brick", "Bridge", "Building", "Ceiling", "Church", "Door", "Hospital", "Hotel", "House", "Hut", "Inn", "Palace", "Pyramid", "Room", "Sandcastle", "School", "Shop", "Skyscraper", "Square", "Stairs", "Tower", "Wall", "Windmill"
        ],
        .arts: [
            "Band", "Beat", "Brush", "Cello", "Chime", "Circus", "Comic", "Concert", "Curtain", "Dance", "Dart", "Drums", "Fiddle", "Film", "Flute", "Frisbee", "Genre", "Guitar", "Lyrics", "Modern", "Music", "Opera", "Paint", "Parody", "Piano", "Play", "Poetry", "Puppet", "Song", "Speakers", "String", "Swing", "Theater", "Trumpet", "Tuba", "Ukulele", "Violin", "Wax", "Whistle"
        ],
        .body: [
            "Acne", "Ankle", "Arm", "Back", "Bald", "Body", "Chest", "Dimple", "Ear", "Elbow", "Eye", "Eyebrow", "Face", "Finger", "Foot", "Forehead", "Freckle", "Hair", "Head", "Knee", "Leg", "Mole", "Mouth", "Nose", "Organ", "Rib", "Thumb", "Vision"
        ],
        .clothing: [
            "Belt", "Boot", "Bowtie", "Cloak", "Dress", "Glasses", "Hat", "Jeans", "Lace", "Laundry", "Pajamas", "Pants", "Pocket", "Shirt", "Shoe", "Shoelace", "Sock", "Suit", "Sweater", "Tie", "Underwear", "Vest", "Wig", "Zipper"
        ],
        .foodAndDrinks: [
            "Avocado", "Baguette", "Banana", "Bar", "Beer", "Berry", "Broccoli", "Cake", "Candy", "Carrot", "Chocolate", "Cone", "Cream", "Crisp", "Crumb", "Crust", "Drink", "Eat", "Ginger", "Gingerbread", "Grape", "Gum", "Gumball", "Ham", "Honey", "Hungry", "Ice", "Ice Cream", "Jelly", "Kiwi", "Lemon", "Lime", "Lollipop", "Lunch", "Lunchbox", "Mint", "Nut", "Olive", "Pastry", "Pear", "Pepper", "Plate", "Popsicle", "Salt", "Sandwich", "Sugar", "Sushi", "Tea", "Toast", "Watermelon", "Whiskey", "Wine"
        ],
        .game: [
            "Board", "Cards", "Casino", "Checkers", "Chess", "Deck", "Dice", "Dominoes", "Game", "Jigsaw", "Party", "Pawn", "Poker", "Puzzle", "Roulette", "Spycodes"
        ],
        .garden: [
            "Beanstalk", "Blossom", "Fence", "Flower", "Garden", "Grass", "Green", "Hedge", "Hose", "Lawn", "Rose", "Sprinkler", "Weed", "Yard", "Yardstick"
        ],
        .items: [
            "Bag", "Balloon", "Battery", "Bed", "Bib", "Blanket", "Bolt", "Book", "Bottle", "Box", "Broom", "Bulb", "Button", "Can", "Candle", "Cape", "Card", "Chair", "Clock", "Computer", "Cord", "Crayon", "Dictionary", "Doll", "Drill", "Fan", "File", "Flashlight", "Glass", "Glove", "Journal", "Key", "Kite", "Knife", "Ladder", "Marble", "Matchstick", "Mattress", "Mop", "Nail", "Needle", "Pen", "Pencil", "Penny", "Phone", "Photograph", "Pillow", "Pin", "Radio", "Raft", "Rag", "Ring", "Ruler", "Sponge", "Spool", "Spoon", "Table", "Tablet", "Telephone", "Television", "Tool", "Toothbrush", "Torch", "Vacuum", "Watch", "Wheelchair", "Whip"
        ],
        .nature: [
            "Air", "Cabin", "Campsite", "Chalk", "Clay", "Coal", "Cold", "Dawn", "Day", "Diamond", "Dust", "Elm", "Field", "Fire", "Fog", "Forest", "Gem", "Hill", "Island", "Ivy", "Jade", "Log", "Maple", "Mold", "Mountain", "Mud", "Nature", "Night", "Ocean", "Park", "Quicksand", "Rainbow", "Rainwater", "Rock", "Root", "Sea", "Seashell", "Season", "Snow", "Spring", "Stream", "Swamp", "Thunder", "Tide", "Tornado", "Tree", "Twig", "Water", "Waterfall", "Wave", "Wind", "Winter"
        ],
        .people: [
            "Agent", "Angel", "Aunt", "Boy", "Bride", "Chef", "Clown", "Conductor", "Cook", "Cowboy", "Crown", "Dad", "Dentist", "Diver", "Doctor", "Elf", "Genius", "Giant", "Girl", "Goblin", "Grandpa", "Intern", "King", "Knight", "Lawyer", "Life", "Lifestyle", "Maid", "Mom", "Neighbor", "Niece", "Ninja", "Pilot", "Pirate", "Plumber", "Police", "President", "Princess", "Punk", "Queen", "Scientist", "Server", "Sheriff", "Singer", "Soldier", "Spy", "Student", "Superhero", "Teacher", "Teenager", "Thief", "Tutor", "Witch", "Young"
        ],
        .places: [
            "Africa", "Amazon", "America", "Atlantis", "Australia", "Beijing", "Berlin", "Canada", "China", "College", "Dubai", "Egypt", "England", "Europe", "France", "Germany", "Greece", "Hollywood", "Hong Kong", "India", "Japan", "London", "Los Angeles", "Mexico", "New York", "Paris", "Phoenix", "Rome", "San Francisco", "Shanghai", "Spain", "Sydney", "Tokyo", "Toronto", "University", "Vancouver", "World"],
        .space: [
            "Alien", "Asteroid", "Astronaut", "Comet", "Earth", "Galaxy", "Jupiter", "Laser", "Lightsaber", "Mars", "Mercury", "Moon", "Neptune", "Orbit", "Pluto", "Satellite", "Saturn", "Space", "Star", "Sun", "Telescope", "Universe", "Uranus", "Venus"
        ],
        .sports: [
            "Athlete", "Ball", "Baseball", "Basketball", "Bat", "Beach", "Bicycle", "Biking", "Champion", "Cliff", "Climb", "Court", "Cricket", "Cycle", "Football", "Gold", "Hockey", "Hurdle", "Jog", "Jump", "Match", "Oar", "Olympian", "Pool", "Race", "Racket", "Rink", "Skate", "Skating", "Ski", "Soccer", "Stadium", "Swimming", "Tennis", "Track"
        ],
        .transportation: [
            "Airplane", "Boat", "Bus", "Car", "Coach", "Cruise", "Engine", "Freight", "Helicopter", "Limousine", "Motorcycle", "Ship", "Taxi", "Tire", "Tractor", "Train", "Truck", "Van"
        ],
        .misc: [
            "Asleep", "Band", "Big", "Bill", "Billboard", "Birthday", "Bite", "Black", "Block", "Blue", "Blur", "Bomb", "Booth", "Brand", "Brave", "Brown", "Bubble", "Buddy", "Buy", "Cardboard", "Cell", "Century", "Charge", "Club", "Clue", "Coaster", "Code", "Cough", "Cross", "Cuff", "Date", "Deep", "Degree", "Desk", "Dirty", "Ditch", "Dot", "Draft", "Drain", "Draw", "Dream", "Drip", "Dryer", "Dump", "Dunk", "Fair", "Fancy", "Fast", "Feast", "First", "Fix", "Flu", "Flush", "Foil", "Forever", "Fountain", "Frown", "Ghost", "Gray", "Ground", "Half", "Handle", "Hang", "Happy", "Hatch", "Haunted", "Hide", "Hole", "Homework", "Honk", "Hook", "Hot", "Hug", "Hurt", "Internet", "Kilogram", "Kitchen", "Lab", "Lag", "Lap", "Laugh", "Letter", "Level", "Light", "Line", "Link", "Loyalty", "Luck", "Machine", "Mail", "Mailbox", "March", "Mark", "Mascot", "Mess", "Mine", "Mistake", "Monday", "Money", "Nightmare", "Note", "Office", "Old", "Orange", "Outside", "Pan", "Paper", "Parachute", "Part", "Pass", "Password", "Picnic", "Ping", "Pinwheel", "Pipe", "Pit", "Plan", "Plastic", "Playground", "Plot", "Plow", "Point", "Poison", "Pole", "Pomp", "Pong", "Port", "Positive", "Post", "Pound", "Present", "Purple", "Push", "Quiet", "Random", "Ray", "Recycle", "Red", "Regret", "Riddle", "Robot", "Round", "Row", "Sad", "Safe", "Sandbox", "Scar", "Scared", "Scramble", "Screen", "Scuff", "Sentence", "Set", "Shadow", "Shallow", "Shampoo", "Sheets", "Shipwreck", "Short", "Shower", "Sick", "Silhouette", "Sink", "Sip", "Slam", "Sleep", "Sling", "Slow", "Slump", "Smith", "Sneeze", "Snuggle", "Spare", "Spell", "Spot", "Squint", "Stand", "State", "Stick", "Stock", "Stop", "Stove", "Straw", "Stripe", "Sub", "Sunburn", "Swarm", "Tag", "Talk", "Tap", "Throne", "Time", "Tissue", "Toilet", "Treasure", "Triangle", "Trip", "Tube", "Violet", "War", "Web", "Wedding", "Well", "Zero", "Zone"
        ]
    ]

    static func getWordCount(category: Category) -> Int {
        guard let list = SCWordBank.bank[category] else {
            return 0
        }

        return list.count
    }

    static func getShuffledWords() -> [String] {
        var list = [String]()
        // TODO: Allow custom categories to be added to shuffling list
        for (_, value) in SCWordBank.bank {
            list += value
        }

        return list.choose(SCConstants.constant.cardCount.rawValue)
    }
}
