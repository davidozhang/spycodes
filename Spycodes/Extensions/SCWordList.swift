import Foundation

class SCWordList {
    fileprivate static let list = ["Acne", "Acre", "Airplane", "Aisle", "Alligator", "America", "Ankle", "Applause", "Application", "Arm", "Armada", "Asleep", "Astronaut", "Athlete", "Atlantis", "Aunt", "Avocado", "Bag", "Baguette", "Bald", "Balloon", "Banana", "Baseball", "Basketball", "Bat", "Battery", "Beach", "Beanstalk", "Beer", "Belt", "Bib", "Bicycle", "Big", "Bike", "Billboard", "Bird", "Birthday", "Bite", "Blacksmith", "Blanket", "Bleach", "Blimp", "Blossom", "Blueprint", "Blur", "Boa", "Boat", "Bobsled", "Body", "Bomb", "Book", "Booth", "Bowtie", "Box", "Boy", "Brainstorm", "Brand", "Brave", "Brick", "Bride", "Bridge", "Broccoli", "Broken", "Broom", "Bubble", "Buddy", "Buffalo", "Bulb", "Bunny", "Bus", "Buy", "Cabin", "Cake", "Campsite", "Can", "Canada", "Candle", "Candy", "Cape", "Car", "Cardboard", "Cat", "Ceiling", "Cell", "Century", "Chair", "Chalk", "Champion", "Chef", "Chess", "Chicken", "Chime", "China", "Chocolate", "Church", "Circus", "Clay", "Cliff", "Climb", "Cloak", "Clockwork", "Clown", "Clue", "Coach", "Coal", "Coaster", "Cold", "College", "Comfort", "Computer", "Cone", "Conversation", "Cook", "Coop", "Cord", "Cough", "Cow", "Cowboy", "Crayon", "Cream", "Crisp", "Crow", "Cruise", "Crumb", "Crust", "Cuff", "Curtain", "Dad", "Dart", "Dawn", "Day", "Deep", "Dent", "Dentist", "Desk", "Dictionary", "Dimple", "Dirty", "Dismantle", "Ditch", "Diver", "Doctor", "Dog", "Doghouse", "Doll", "Dominoes", "Door", "Dot", "Drain", "Draw", "Dream", "Dress", "Drink", "Drip", "Drums", "Dryer", "Duck", "Dump", "Dunk", "Dust", "Ear", "Eat", "Elbow", "Electricity", "Elephant", "Elevator", "Elf", "Elm", "Engine", "England", "Escalator", "Eureka", "Europe", "Eyebrow", "Fan", "Fancy", "Fast", "Feast", "Fence", "Fiddle", "Finger", "Fire", "First", "Fish", "Fix", "Flagpole", "Flashlight", "Flock", "Flower", "Flu", "Flush", "Fog", "Foil", "Football", "Forehead", "Forever", "Fountain", "France", "Freckle", "Freight", "Frog", "Frown", "Gallop", "Game", "Garbage", "Garden", "Gasoline", "Gem", "Ginger", "Gingerbread", "Girl", "Glasses", "Goblin", "Gold", "Goodbye", "Grandpa", "Grape", "Grass", "Gray", "Green", "Guitar", "Gum", "Gumball", "Hair", "Half", "Handle", "Handwriting", "Hang", "Happy", "Hat", "Hatch", "Haunted", "Heart", "Hedge", "Helicopter", "Hide", "Hill", "Hockey", "Homework", "Honk", "Horse", "Hose", "Hot", "House", "Houseboat", "Hug", "Hungry", "Hurdle", "Hurt", "Hut", "Ice", "Inn", "Intern", "Internet", "Ivory", "Ivy", "Jade", "Japan", "Jeans", "Jelly", "Jet", "Jog", "Journal", "Jump", "Key", "Killer", "Kilogram", "King", "Kitchen", "Kite", "Knee", "Knife", "Knight", "Koala", "Lace", "Ladder", "Ladybug", "Lag", "Landfill", "Lap", "Laugh", "Laundry", "Law", "Lawn", "Leak", "Leg", "Letter", "Level", "Lifestyle", "Light", "Lightsaber", "Lime", "Lion", "Lizard", "Log", "Lollipop", "Loyalty", "Lunch", "Lunchbox", "Lyrics", "Machine", "Mailbox", "Mammoth", "Mark", "Mars", "Mascot", "Matchstick", "Mate", "Mattress", "Mess", "Mexico", "Mine", "Mistake", "Modern", "Mold", "Mom", "Monday", "Money", "Monitor", "Monster", "Moon", "Mop", "Moth", "Motorcycle", "Mountain", "Mouse", "Mud", "Music", "Mute", "Nature", "Neighbor", "Nest", "Niece", "Night", "Nightmare", "Nose", "Oar", "Ocean", "Office", "Oil", "Old", "Olympian", "Orbit", "Organ", "Outside", "Ovation", "Overture", "Paint", "Pajamas", "Palace", "Pants", "Paper", "Park", "Parody", "Party", "Password", "Pastry", "Pawn", "Pear", "Pen", "Pencil", "Penny", "Pepper", "Personal", "Phone", "Photograph", "Piano", "Picnic", "Pillow", "Pilot", "Ping", "Pinwheel", "Pirate", "Plan", "Plate", "Platypus", "Playground", "Plow", "Plumber", "Pocket", "Poem", "Point", "Pole", "Pomp", "Pong", "Pool", "Popsicle", "Positive", "Post", "Present", "President", "Princess", "Punk", "Puppet", "Puppy", "Push", "Puzzle", "Queen", "Quicksand", "Quiet", "Race", "Radio", "Raft", "Rag", "Rainbow", "Rainwater", "Random", "Ray", "Recycle", "Red", "Regret", "Rib", "Riddle", "Rim", "Rink", "Rock", "Room", "Rose", "Round", "Roundabout", "Rung", "Runt", "Rut", "Sad", "Safe", "Salmon", "Salt", "Sandbox", "Sandcastle", "Sandwich", "Satellite", "Scar", "Scared", "School", "Scramble", "Scuff", "Sea", "Seashell", "Season", "Sentence", "Set", "Shallow", "Shampoo", "Shark", "Sheep", "Sheets", "Sheriff", "Ship", "Shipwreck", "Shirt", "Shoelace", "Short", "Shower", "Sick", "Silhouette", "Singer", "Sip", "Skate", "Skating", "Ski", "Slam", "Sleep", "Sling", "Slow", "Slump", "Smith", "Sneeze", "Snow", "Snuggle", "Song", "Soccer", "Space", "Spare", "Speakers", "Spider", "Spit", "Sponge", "Spool", "Spoon", "Spring", "Sprinkler", "Spy", "Square", "Squint", "Stairs", "Stand", "Star", "State", "Stick", "Stock", "Stop", "Stove", "Straw", "Stream", "Stripe", "Student", "Sun", "Sunburn", "Sushi", "Swamp", "Swarm", "Sweater", "Swimming", "Swing", "Tail", "Talk", "Taxi", "Teacher", "Teapot", "Teenager", "Telephone", "Ten", "Tennis", "Thief", "Think", "Throne", "Thunder", "Tide", "Tiger", "Time", "Tire", "Tissue", "Toast", "Toilet", "Tool", "Toothbrush", "Tornado", "Tractor", "Train", "Trash", "Treasure", "Tree", "Triangle", "Trip", "Truck", "Tub", "Tuba", "Tutor", "Television", "Twang", "Twig", "Type", "Underwear", "Universe", "University", "Vest", "Vision", "War", "Watch", "Water", "Watermelon", "Wax", "Wedding", "Weed", "Wheelchair", "Whiplash", "Whiskey", "Whistle", "White", "Wig", "Wind", "Windmill", "Wine", "Winter", "Wolf", "Wool", "World", "Worm", "Yardstick", "Young", "Zamboni", "Zen", "Zero", "Zipper", "Zone", "Zoo"]

    static func getShuffledWords() -> [String] {
        return self.list.choose(SCConstants.constant.cardCount.rawValue)
    }
}
