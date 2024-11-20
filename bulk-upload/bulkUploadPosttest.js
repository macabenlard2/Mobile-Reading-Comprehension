// Import necessary modules
const admin = require("firebase-admin");
const serviceAccount = require("./serviceAccountKey.json");

// Initialize the Firebase Admin SDK
admin.initializeApp({
  credential: admin.credential.cert(serviceAccount),
  databaseURL: "https://eduassess-52e66-default-rtdb.firebaseio.com" // Replace with your database URL
});

const db = admin.firestore();

async function bulkUpload() {
  // Array of passages and quizzes to upload
  const passages = [
    {
        "title": "The Bib",
        "content": "Bim-bim has a bib. It is from Tina. The bib is red. It is pretty. But the bib is big. Will this fit? “I will get a pin,” says Dad. “There. It fits!”",
        "type": "post test",
        "gradeLevel": "Grade 2",
        "set": "Set A",
        "quizzes": [
            {
                "question": "Who has a bib?",
                "options": ["Den-den", "Bim-bim", "Tin-tin"],
                "correctAnswer": "Bim-bim"
            },
            {
                "question": "What is the color of the bib?",
                "options": ["red", "pink", "yellow"],
                "correctAnswer": "red"
            },
            {
                "question": "Who gave the bib?",
                "options": ["Dad", "Mama", "Tina"],
                "correctAnswer": "Tina"
            },
            {
                "question": "What is the problem with the bib?",
                "options": ["It is big.", "It is wet.", "It has a rip."],
                "correctAnswer": "It is big."
            },
            {
                "question": "How did the bib fit Bim-bim?",
                "options": ["Mama cut it.", "Grandma fixed it.", "Dad put a pin on it."],
                "correctAnswer": "Dad put a pin on it."
            }
        ]
    },
    {
        "title": "The Egg on the Grass",
        "content": "Duck, Hen, and Bird are in the garden. “I see a big, round egg on the grass,” says Bird. “It is not my egg,” says Hen. “My egg is in the nest.” “It is not my egg,” says Duck. “My eggs just hatched.” “It is not an egg,” says Ben. “It’s my rubber ball.”",
        "type": "post test",
        "gradeLevel": "Grade 3",
        "set": "Set A",
        "quizzes": [
            {
                "question": "Where are Bird, Hen, and Duck?",
                "options": ["in the nest", "in the garden", "in the farmhouse"],
                "correctAnswer": "in the garden"
            },
            {
                "question": "Who saw the egg first?",
                "options": ["the hen", "the duck", "the bird"],
                "correctAnswer": "the bird"
            },
            {
                "question": "What word tells about the egg?",
                "options": ["big and round", "white and shiny", "tiny and colorful"],
                "correctAnswer": "big and round"
            },
            {
                "question": "Who among the animals has a new baby?",
                "options": ["the hen", "the bird", "the duck"],
                "correctAnswer": "the duck"
            },
            {
                "question": "What was the 'egg' that the animals saw?",
                "options": ["a large top", "a rubber ball", "a plastic cup"],
                "correctAnswer": "a rubber ball"
            },
            {
                "question": "Why did the animals think that the rubber ball is an egg?",
                "options": ["It is tiny.", "It is white.", "It is round."],
                "correctAnswer": "It is round."
            }
        ]
    },
    {
        "title": "The Tricycle Man",
        "content": "Nick is a tricycle man. He waits for riders every morning. “Please take me to the bus station,” says Mr. Perez. “Please take me to the market,” says Mrs. Pardo. “Please take us to school,” say Mike and Kris. “But I can take only one of you,” says Nick to the children. “Oh, I can sit behind you, Nick,” says Mr. Perez. “Kris or Mike can take my seat.” “Thank you, Mr. Perez,” say Mike and Kris.",
        "type": "post test",
        "gradeLevel": "Grade 4",
        "set": "Set A",
        "quizzes": [
            {
                "question": "Who is the tricycle man?",
                "options": ["Mike", "Nick", "Mr. Perez"],
                "correctAnswer": "Nick"
            },
            {
                "question": "What was Nick’s problem?",
                "options": ["There was a lot of traffic.", "He could not take the children to school.", "There was only one seat for either Kris or Mike."],
                "correctAnswer": "There was only one seat for either Kris or Mike."
            },
            {
                "question": "How many riders did the tricycle man have?",
                "options": ["two", "four", "three"],
                "correctAnswer": "three"
            },
            {
                "question": "Who helped solve Nick’s problem?",
                "options": ["Mr. Perez", "Mrs. Pardo", "another tricycle driver"],
                "correctAnswer": "Mr. Perez"
            },
            {
                "question": "Which word describes Mr. Perez?",
                "options": ["kind", "strict", "proud"],
                "correctAnswer": "kind"
            },
            {
                "question": "Which happened last?",
                "options": ["Mr. Perez told Nick to take him to the bus station.", "Mrs. Pardo told Nick to take her to the market.", "Kris and Mike told Nick to take them to school."],
                "correctAnswer": "Kris and Mike told Nick to take them to school."
            }
        ]
    },
    {
        "title": "The Snail with the Biggest House",
        "content": "A little snail told his father, “I want to have the biggest house.” “Keep your house light and easy to carry,” said his father. But, the snail ate a lot until his house grew enormous. “You now have the biggest house,” said the snails. After a while, the snails have eaten all the grass on the farm. They decided to move to another place. “Help! I cannot move,” said the snail with the biggest house. The snails tried to help, but the house was too heavy. So the snail with the biggest house was left behind.",
        "type": "post test",
        "gradeLevel": "Grade 5",
        "set": "Set A",
        "quizzes": [
            {
                "question": "What kind of house did the father snail want the little snail to have?",
                "options": ["big and tidy", "hard and durable", "large and colorful", "light and easy to carry"],
                "correctAnswer": "light and easy to carry"
            },
            {
                "question": "The house grew enormous. A synonym of enormous is",
                "options": ["huge", "lovely", "different", "expensive"],
                "correctAnswer": "huge"
            },
            {
                "question": "Why will the snails move to another place?",
                "options": ["Their enemies bother them.", "They want to see other places.", "They have eaten all the grass on the farm.", "They don’t want to be with the snail with the biggest house."],
                "correctAnswer": "They have eaten all the grass on the farm."
            },
            {
                "question": "What was the little snail’s problem when they were about to move?",
                "options": ["“Will I build another house?”", "“How can I carry my very big house?”", "“What will happen to my biggest house?”", "“What if another snail will have a house bigger than mine?”"],
                "correctAnswer": "“How can I carry my very big house?”"
            },
            {
                "question": "Why did the other snails leave the little snail behind?",
                "options": ["He eats too much grass.", "They did not want to be with him.", "They could not move his very big house.", "The little snail did not want to leave its house."],
                "correctAnswer": "They could not move his very big house."
            },
            {
                "question": "Which of the following did the little snail think at the end?",
                "options": ["“My friends did not help me at all.”", "“I should have stored more grass and leaves in my house.”", "“Father was right. I should have a house that is easy to carry.”", "“Never mind if I stay behind. I have the biggest house anyway.”"],
                "correctAnswer": "“Father was right. I should have a house that is easy to carry.”"
            },
            {
                "question": "Which of the following will most likely happen to the little snail?",
                "options": ["It will die of hunger.", "It will destroy its house.", "It will follow the other snails.", "It will live happily on the farm."],
                "correctAnswer": "It will die of hunger."
            }
        ]
    },
    {
        "title": "Rocks from Outer Space",
        "content": "The pieces of rocks that come from outer space have three names: meteor, meteorite, and meteoroid. A meteoroid is a piece of matter moving in space. It moves as fast as 40 miles a second. It may be large or small. Most meteoroids are smaller than a grain of sand. As a meteoroid comes into the air near the earth, it catches fire. Most meteoroids burn up before they hit the earth. The flash of light from the burning meteoroid is called a meteor. If a piece of meteoroid falls to the ground, it is called a meteorite. People have studied these rocks for many years. They wanted to research ways to keep meteoroids from making holes in spacecrafts. Thick walls may help, or perhaps spacecrafts can be covered with a metal skin that will seal itself.",
        "type": "post test",
        "gradeLevel": "Grade 6",
        "set": "Set A",
        "quizzes": [
            {
                "question": "Where do the meteoroids originate?",
                "options": ["from the outer layer of the earth", "from the other planets", "from outer space", "from the moon"],
                "correctAnswer": "from outer space"
            },
            {
                "question": "A meteoroid catches fire when",
                "options": ["it hits the earth.", "it falls to the ground.", "it collides with a spacecraft.", "it comes into the air near the earth."],
                "correctAnswer": "it comes into the air near the earth."
            },
            {
                "question": "When is a meteoroid dangerous?",
                "options": ["when it falls to earth and burns down houses", "when it makes holes in a spacecraft", "when it hits airplanes", "when it catches fire"],
                "correctAnswer": "when it makes holes in a spacecraft"
            },
            {
                "question": "The rocks from outer space are studied to find out ______________.",
                "options": ["the time that they fall on earth.", "how these rocks could be used", "how to avoid their fall on earth", "how to keep them from making holes in spacecraft"],
                "correctAnswer": "how to keep them from making holes in spacecraft"
            },
            {
                "question": "What is true of meteoroids, meteorites, and meteors?",
                "options": ["They are all small.", "They are all rocks.", "They all fall to the earth.", "They all turn into balls of fire."],
                "correctAnswer": "They are all rocks."
            },
            {
                "question": "When one sees a flash of light in space, he may exclaim __________.",
                "options": ["“That’s a meteor.”", "“There’s a meteorite.”", "“That’s a meteoroid.”", "“A meteoroid hit a spacecraft.”"],
                "correctAnswer": "“That’s a meteor.”"
            },
            {
                "question": "Which is the best definition of a meteorite?",
                "options": ["a flash of light from a burning meteoroid", "a piece of meteoroid that falls to the ground", "a piece of rock from outer space that hit a spacecraft", "a piece of rock from outer space that burns up before hitting the ground"],
                "correctAnswer": "a piece of meteoroid that falls to the ground"
            },
            {
                "question": "In the sentence, “They research ways to keep meteoroids from making holes in the spacecraft,” another word for research is __________.",
                "options": ["study", "solve", "conclude", "experiment"],
                "correctAnswer": "study"
            }
        ]
    },
    {
        "title": "Diving",
        "content": "Humans do not have the capacity to breathe underwater unaided by external devices. A diver who wants to stay underwater for more than a few minutes must breathe air on a special mixture of gases. He can wear diving suits and have air pumped to him from above or he can carry tanks of air on his back and breathe through a hose and a mouthpiece. Early divers discovered that it is not enough to supply air to breathe comfortably underwater. The diver’s body is under great pressure in deep water because water weighs 800 times as much as air. Tons of water push against the diver deep in the sea. When this happens, his blood takes in some of the gases he breathes. When the diver rises to the surface, the water pressure becomes less. If he rises too quickly, the gases in his blood form bubbles that make breathing difficult. He suffers from bends, causing him to double up in pain.",
        "type": "post test",
        "gradeLevel": "Grade 7",
        "set": "Set A",
        "quizzes": [
            {
                "question": "What is the purpose of the diving suit?",
                "options": ["to track the diver’s location", "to make the diver stay afloat", "to dive to the bottom of the sea faster", "to pump air from the surface of the sea"],
                "correctAnswer": "to pump air from the surface of the sea"
            },
            {
                "question": "The hose and the mouthpiece of the diver are used _____________.",
                "options": ["for breathing", "for finding direction", "for lighting the way", "for communicating"],
                "correctAnswer": "for breathing"
            },
            {
                "question": "The second paragraph informs the reader that _________________.",
                "options": ["water is heavier than air", "it is easy to float on the water", "it is exciting to stay underwater", "it is difficult to breathe while diving"],
                "correctAnswer": "water is heavier than air"
            },
            {
                "question": "It is easy for swimmers to float in the water’s surface because",
                "options": ["they can see where they are heading for", "there is lesser water pressure", "there is more air to breathe", "there is minimal danger"],
                "correctAnswer": "there is lesser water pressure"
            },
            {
                "question": "From the phrase ‘a diver suffers from bends,’ the reader can guess that a bend is",
                "options": ["a reverse turn", "an intense pain", "a wrong direction", "an incorrect information"],
                "correctAnswer": "an intense pain"
            },
            {
                "question": "To avoid pain when rising to the surface, a diving instructor should tell a swimmer to",
                "options": ["“go up as fast as you can”", "“swim to the surface slowly”", "“avoid bringing things from undersea”", "“inspect your hose and mouthpiece first”"],
                "correctAnswer": "“swim to the surface slowly”"
            },
            {
                "question": "Which statement is true in the selection? Water pressure",
                "options": ["is heavier on the sea surface", "is greater in the deep part of the sea", "feels more while one is going up the surface", "is the same on the surface and in the deep part of the sea"],
                "correctAnswer": "is greater in the deep part of the sea"
            },
            {
                "question": "Who among the following readers will benefit most from this selection?",
                "options": ["the sea divers", "the coast guards", "the sea travelers", "the swimming instructors"],
                "correctAnswer": "the sea divers"
            }
        ]
    },

    {
        "title": "Bam and Tagpi",
        "content": "Bam is sad. “Where is Tagpi?” Where is my pet dog? I want to play with him. He is not in the room.” “Aw! Aw!” “Where are you, Tagpi? Oh, you are in the garden.”",
        "type": "post test",
        "gradeLevel": "Grade 2",
        "set": "Set B",
        "quizzes": [
            {
                "question": "Who is Tagpi?",
                "options": ["the pet dog of Bam", "the brother of Bam", "the classmate of Bam"],
                "correctAnswer": "the pet dog of Bam"
            },
            {
                "question": "Where did Bam first look for Tagpi?",
                "options": ["in the room", "in the kitchen", "in the garden"],
                "correctAnswer": "in the room"
            },
            {
                "question": "Why did Bam look for Tagpi?",
                "options": ["He wants to feed Tagpi.", "He wants to play with Tagpi.", "He wants to give Tagpi a bath."],
                "correctAnswer": "He wants to play with Tagpi."
            },
            {
                "question": "Where did Bam find Tagpi?",
                "options": ["in the hut", "in the garden", "under the bed"],
                "correctAnswer": "in the garden"
            },
            {
                "question": "What did Bam feel when he found Tagpi?",
                "options": ["sad", "mad", "glad"],
                "correctAnswer": "glad"
            }
        ]
    },
    {
        "title": "The Caps and the Kittens",
        "content": "Dan and Pepe will play. “But the sun is hot,” says Pepe. “Let us get our caps,” says Dan. “My cap is not on my bed,” says Pepe. “My cap is not in my bag,” says Dan. “Look boys! Our cat has kittens,” says Mama. “Mik-mik has four kittens!” says Dan. “Yay! The kittens nap in our caps!”",
        "type": "post test",
        "gradeLevel": "Grade 3",
        "set": "Set B",
        "quizzes": [
            {
                "question": "Why did Dan and Pepe need their caps?",
                "options": ["The sun is hot.", "They will play with their caps.", "They will give the caps to the kittens."],
                "correctAnswer": "The sun is hot."
            },
            {
                "question": "What did Mama want them to look at?",
                "options": ["the bag", "the bed", "the kittens"],
                "correctAnswer": "the kittens"
            },
            {
                "question": "Who is Mik-mik?",
                "options": ["the pet cat", "the fat kitten", "the big dog"],
                "correctAnswer": "the pet cat"
            },
            {
                "question": "What did the kittens use the caps for?",
                "options": ["for playing", "for sleeping on", "for keeping them free from the hot sun"],
                "correctAnswer": "for sleeping on"
            },
            {
                "question": "What did the boys feel when they saw the kittens?",
                "options": ["sad", "mad", "happy"],
                "correctAnswer": "happy"
            },
            {
                "question": "What do you think will the boys do after?",
                "options": ["The boys will send the kittens away.", "The boys will take the caps from the kittens.", "The boys will let the kittens sleep on their caps."],
                "correctAnswer": "The boys will let the kittens sleep on their caps."
            }
        ]
    },
    {
        "title": "Cat and Mouse",
        "content": "A mouse and a cat lived in an old house. The mouse stayed in a hole while the cat slept under the table. One night, the mouse got out of its hole. “Mmm, Cheese!” it thought, as it went up the table. As it started nibbling the cheese, a fork fell. It woke the cat up so it ran up the table. But the mouse was too fast for the cat. It quickly dashed to its hole. Safe at last!",
        "type": "post test",
        "gradeLevel": "Grade 4",
        "set": "Set B",
        "quizzes": [
            {
                "question": "Where did the cat and the mouse live?",
                "options": ["in a big hole", "in an old house", "under the dining table"],
                "correctAnswer": "in an old house"
            },
            {
                "question": "Why did the mouse get out of its hole?",
                "options": ["to find a mate", "to look for food", "to play with the cat"],
                "correctAnswer": "to look for food"
            },
            {
                "question": "Why did the cat wake up?",
                "options": ["It smelled the food.", "The mouse asked it to play.", "It heard the noise made by the fork."],
                "correctAnswer": "It heard the noise made by the fork."
            },
            {
                "question": "In order to catch the mouse, what could the cat do next time?",
                "options": ["run faster", "sleep later", "stay alert for loud sounds"],
                "correctAnswer": "stay alert for loud sounds"
            },
            {
                "question": "Which happened last in the story?",
                "options": ["The mouse smelled the food on the table.", "The cat woke up and chased the mouse.", "The mouse ran to its hole."],
                "correctAnswer": "The mouse ran to its hole."
            },
            {
                "question": "Why was the mouse thankful at the end of the story?",
                "options": ["It was able to get away from the cat.", "It ate bread and cheese.", "It saw the cat."],
                "correctAnswer": "It was able to get away from the cat."
            }
        ]
    },
    {
        "title": "The Great Runner",
        "content": "Atalanta is a lovely princess and a great runner. One day, her father told her, “It’s time you get married.” “I will marry a man who will beat me in a race,” replied Atalanta. Many young men tried their luck. But they all lost. Hippomenes asked the goddess of love for help. “Here are three golden apples,” she said. “During the race, throw one apple in front of Atalanta. She will stop to pick it up. That should slow her down.” Hippomenes heeded her advice and won the race. Thus, Atalanta became his wife.",
        "type": "post test",
        "gradeLevel": "Grade 5",
        "set": "Set B",
        "quizzes": [
            {
                "question": "Which sentence says something about Atalanta?",
                "options": ["She did not want to get married.", "She was an obedient daughter.", "She was a great runner.", "She loved Hippomenes."],
                "correctAnswer": "She was a great runner."
            },
            {
                "question": "What kind of man would she marry?",
                "options": ["a kind prince", "a clever ruler", "a great runner", "a handsome man"],
                "correctAnswer": "a great runner"
            },
            {
                "question": "Hippomenes became Atalanta’s ________________.",
                "options": ["friend", "enemy", "adviser", "husband"],
                "correctAnswer": "husband"
            },
            {
                "question": "Many tried their luck. When one tries his luck, he _________",
                "options": ["always wins.", "is sure to win.", "really wants to win.", "attempts to win."],
                "correctAnswer": "attempts to win."
            },
            {
                "question": "Hippomenes heeded Aphrodite’s advice. The synonym of heeded is",
                "options": ["followed", "disobeyed", "laughed at", "disregarded"],
                "correctAnswer": "followed"
            },
            {
                "question": "Who was Aphrodite?",
                "options": ["the godmother of Hippomenes", "the mother of Atalanta", "the goddess of love", "the great teacher"],
                "correctAnswer": "the goddess of love"
            },
            {
                "question": "How did the golden apples help Hippomenes win?",
                "options": ["They had magic powers.", "They made Atalanta sleepy.", "They delayed Atalanta during the race.", "They gave Hippomenes strength in running."],
                "correctAnswer": "They delayed Atalanta during the race."
            }
        ]
    },
    {
        "title": "Beetles",
        "content": "Beetles can adapt to any kind of environment. They can be found crawling, burrowing, flying, and swimming on every part of the earth except the ocean. Why do beetles survive well on our planet? First, they have tough compact bodies. These help them hide, find food, and lay eggs in places where other insects could never go. Almost all beetles have tough front wings which are colorful and carry beautiful patterns. These wings also act as a suit of armor to protect the beetles’ transparent hind wings which are used for flying. Beetles have mouth parts designed for chewing different food. They eat other insects, animal dung, and even cloth. They also feed on the bark, leaves, flowers, and fruits of any kind of plant. They can even chew around the stems of poisonous plants to let the deadly sap drain.",
        "type": "post test",
        "gradeLevel": "Grade 6",
        "set": "Set B",
        "quizzes": [
            {
                "question": "In which of these places WON’T you find beetles?",
                "options": ["in the mountain", "in the plains", "in the sea", "in the hill"],
                "correctAnswer": "in the sea"
            },
            {
                "question": "In the sentence Beetles can adapt to any kind of environment, which is a synonym of adapt?",
                "options": ["get used to", "change", "crawl", "eat"],
                "correctAnswer": "get used to"
            },
            {
                "question": "What pair of words describe the beetles’ front wings?",
                "options": ["transparent and thick", "tough and colorful", "wide and thick", "silky and soft"],
                "correctAnswer": "tough and colorful"
            },
            {
                "question": "What is the use of the beetles’ hind wings?",
                "options": ["for protecting the front wings", "for covering the body", "for finding food", "for flying"],
                "correctAnswer": "for flying"
            },
            {
                "question": "Which of the following states the main idea of this selection?",
                "options": ["reasons why beetles can survive anywhere", "places where one can find beetles", "the compact body of the beetles", "the food that beetles eat"],
                "correctAnswer": "reasons why beetles can survive anywhere"
            },
            {
                "question": "What action of the beetle means making a hole in the ground?",
                "options": ["burrowing", "swimming", "crawling", "flying"],
                "correctAnswer": "burrowing"
            },
            {
                "question": "The front wings of most beetles ____________.",
                "options": ["are transparent", "hide the beetles", "protect the hind wings", "maybe used for swimming"],
                "correctAnswer": "protect the hind wings"
            },
            {
                "question": "If someone says, “You eat like a beetle” it means that ___________.",
                "options": ["You are a picky eater.", "You can eat anything.", "You don’t have appetite.", "You eat very little amount of food."],
                "correctAnswer": "You can eat anything."
            }
        ]
    },
    {
        "title": "The Brain",
        "content": "The brain is the center of the nervous system. It interprets stimuli and tells the body how to react. The brain has three major parts. The part that controls balance, coordination and muscle movement is called the cerebellum. It makes sure that the muscles work well together. For example, a gymnast is able to balance on a beam because of the cerebellum. The medulla is a long stem that connects the brain to the spinal cord. It tells one’s body to do things without thinking about them. Digesting food or breathing even while asleep are examples of these involuntary actions. On the other hand, there are actions that one decides to do. It is the largest part of the brain—the cerebrum—that is responsible for these voluntary movements. Without it, one will not be able to kick a ball or dance at all. The brain might seem small but it is so powerful as it controls one’s entire body.",
        "type": "post test",
        "gradeLevel": "Grade 7",
        "set": "Set B",
        "quizzes": [
            {
                "question": "Which is the best description of the brain?",
                "options": ["It makes people intelligent.", "It keeps one’s body healthy.", "It helps everyone think well.", "It dictates how the body will react to stimuli."],
                "correctAnswer": "It dictates how the body will react to stimuli."
            },
            {
                "question": "In the sentence, “The brain interprets stimuli,” the meaning of interpret is ________.",
                "options": ["assign roles", "recall facts", "discuss ideas", "make sense of"],
                "correctAnswer": "make sense of"
            },
            {
                "question": "What will the brain likely tell you if you happen to hold on to something hot?",
                "options": ["“I wonder how hot it is.”", "“Don’t drop it!”", "“Hold tight!”", "“Let go!”"],
                "correctAnswer": "“Let go!”"
            },
            {
                "question": "Which is an example of involuntary action?",
                "options": ["circulating blood all over the body", "punching one’s classmate", "clapping your hands", "tickling your friend"],
                "correctAnswer": "circulating blood all over the body"
            },
            {
                "question": "Which part of the brain connects to the spinal cord?",
                "options": ["the nerves", "the medulla", "the cerebrum", "the cerebellum"],
                "correctAnswer": "the medulla"
            },
            {
                "question": "What is the function of the cerebellum?",
                "options": ["It sends messages to the cerebrum.", "It connects the medulla to the cerebrum.", "It controls balance and muscle movements.", "It tells the parts of the body how they should function."],
                "correctAnswer": "It controls balance and muscle movements."
            },
            {
                "question": "When you want someone to think of the right answer, you might say",
                "options": ["“Use your senses.”", "“Sharpen your cerebrum.”", "“Give your medulla a job.”", "“Let your cerebellum function.”"],
                "correctAnswer": "“Sharpen your cerebrum.”"
            },
            {
                "question": "What is the main idea of the selection?",
                "options": ["The brain controls the senses.", "The brain interprets all actions.", "The brain has three main parts.", "The brain controls one’s entire body"],
                "correctAnswer": "The brain controls one’s entire body"
            }
        ]
    },
    {
        "title": "Pets",
        "content": "I am Pat. I have a pet cat. I am Ben. I have a pet hen. I am Mig. I have a pet pig. I am Det. I too will have a pet.",
        "type": "post test",
        "gradeLevel": "Grade 2",
        "set": "Set C",
        "quizzes": [
            {
                "question": "What is Pat’s pet?",
                "options": ["pig", "cat", "hen"],
                "correctAnswer": "cat"
            },
            {
                "question": "Who has a pet pig?",
                "options": ["Mig", "Pat", "Ben"],
                "correctAnswer": "Mig"
            },
            {
                "question": "How many children have pets?",
                "options": ["two", "four", "three"],
                "correctAnswer": "three"
            },
            {
                "question": "Who has a pet that can lay eggs?",
                "options": ["Mig", "Ben", "Det"],
                "correctAnswer": "Ben"
            },
            {
                "question": "What is the message of the story?",
                "options": ["People can have three pets.", "People can have the same pet.", "People can have different pets."],
                "correctAnswer": "People can have different pets."
            }
        ]
    },
    {
        "title": "A Happy Place",
        "content": "“Come with me,” says Dan. “Where will we go?” Mina asks. “We will go to a happy place that has lots of balloons. We will play, dance, and run. We will have so much fun. We will eat orange cake that our mom and dad baked.” “And then we will sing, Happy birthday, dear Benny!”",
        "type": "post test",
        "gradeLevel": "Grade 3",
        "set": "Set C",
        "quizzes": [
            {
                "question": "Who asked Mina to go to a happy place?",
                "options": ["Mom", "Dan", "Dad"],
                "correctAnswer": "Dan"
            },
            {
                "question": "What word says something about the happy place?",
                "options": ["quiet", "noisy", "far"],
                "correctAnswer": "noisy"
            },
            {
                "question": "What will the children do in the happy place?",
                "options": ["They will sing, skip and hop.", "They will read, write and count.", "They will dance, run and play."],
                "correctAnswer": "They will dance, run and play."
            },
            {
                "question": "Whose birthday is it?",
                "options": ["Dan", "Mina", "Benny"],
                "correctAnswer": "Benny"
            },
            {
                "question": "Which word tells what Dan feels?",
                "options": ["sad", "afraid", "excited"],
                "correctAnswer": "excited"
            },
            {
                "question": "What is the best response that Benny can make after seeing Dan and Mina?",
                "options": ["I’m glad you came.", "I can’t wait to go home.", "I want to sing with you."],
                "correctAnswer": "I’m glad you came."
            }
        ]
    },
    {
        "title": "Marian’s Experiment",
        "content": "Marian came home from school. She went to the kitchen and saw her mother cooking. “Mama, do we have mongo seeds?” asked Marian. “I will do an experiment.” “Yes, we have some in the cabinet,” answered Mama. Marian got some seeds and planted them in a wooden box. She watered the seeds every day. She made sure they got enough sun. After three days, Marian was happy to see stems and leaves sprouting. Her mongo seeds grew into young plants.",
        "type": "post test",
        "gradeLevel": "Grade 4",
        "set": "Set C",
        "quizzes": [
            {
                "question": "What did Marian look for in the kitchen?",
                "options": ["mango seeds", "mongo seeds", "melon seeds"],
                "correctAnswer": "mongo seeds"
            },
            {
                "question": "What did she do with the seeds?",
                "options": ["She played with them.", "She cooked them.", "She planted them."],
                "correctAnswer": "She planted them."
            },
            {
                "question": "Which of the following events happened last?",
                "options": ["Some stems and leaves sprouted from the seeds.", "Marian planted the mongo seeds in a wooden box.", "Marian watered the soil where the seeds were planted."],
                "correctAnswer": "Some stems and leaves sprouted from the seeds."
            },
            {
                "question": "What did Marian know about planting seeds?",
                "options": ["Seeds should be placed in a wooden box in the house.", "Seeds grow whether or not one takes care of them.", "Seeds need water and sunlight in order to grow."],
                "correctAnswer": "Seeds need water and sunlight in order to grow."
            },
            {
                "question": "What can one learn from Marian?",
                "options": ["It is good to be happy.", "It is good to be curious.", "It is good to be obedient."],
                "correctAnswer": "It is good to be curious."
            },
            {
                "question": "Which sentence tells that Marian’s experiment was successful?",
                "options": ["Mother said there were mongo seeds in the cabinet.", "Stems and leaves started to sprout from the seeds.", "The mongo seeds had enough water and sunlight."],
                "correctAnswer": "Stems and leaves started to sprout from the seeds."
            }
        ]
    },
    {
        "title": "Trading Places",
        "content": "On a trip to a university, the driver told the professor, “I’ve heard you give this speech many times. I can deliver it for you.” The professor said, “The people in this university haven’t seen me yet. Give the lecture. I’ll pretend to be your driver.” When they arrived, the driver was introduced to be the professor. He gave an excellent speech. Everybody applauded. Afterwards, somebody asked a question which the driver couldn’t answer. In order to get out of the sticky situation, he said, “Oh, that’s such an easy question. Even my driver can give you the answer!”",
        "type": "post test",
        "gradeLevel": "Grade 5",
        "set": "Set C",
        "quizzes": [
            {
                "question": "Why did the university invite the professor?",
                "options": ["to give a test", "to give a lecture", "to donate books", "to attend classes"],
                "correctAnswer": "to give a lecture"
            },
            {
                "question": "Why was it easy for the driver to pretend he was the professor?",
                "options": ["The professor looked like the driver.", "The driver dressed up like the professor.", "The driver was as intelligent as the professor.", "The participants have not seen the professor yet."],
                "correctAnswer": "The participants have not seen the professor yet."
            },
            {
                "question": "Why was the selection entitled Trading Places?",
                "options": ["The driver could answer the question asked.", "The professor exchanged roles with the driver.", "The driver exchanged seats with the professor.", "The professor seated himself with the audience."],
                "correctAnswer": "The professor exchanged roles with the driver."
            },
            {
                "question": "Based on the selection, how would you describe the professor?",
                "options": ["a boring lecturer", "an excellent driver", "a humorous person", "a generous employer"],
                "correctAnswer": "a humorous person"
            },
            {
                "question": "The driver tried to get out of a sticky situation. What was the sticky situation?",
                "options": ["A participant recognized the professor.", "The driver could not deliver the lecture.", "The professor could not move from his seat.", "The driver did not know what to answer."],
                "correctAnswer": "The driver did not know what to answer."
            },
            {
                "question": "Why did the driver say “Even my driver can give you the answer!”?",
                "options": ["to admit that even he did not know how to answer", "to stop the audience from asking more questions", "to stop the real professor from answering the question", "to prove to the participants that the question was easy"],
                "correctAnswer": "to prove to the participants that the question was easy"
            },
            {
                "question": "He gave a very good speech and everybody applauded. Another word for applauded is ________.",
                "options": ["kept very quiet", "started to leave", "clapped their hands", "asked him to speak louder"],
                "correctAnswer": "clapped their hands"
            }
        ]
    },
    {
        "title": "Just How Fast",
        "content": "Many things around us move at different rates. Glaciers, which are frozen rivers of snow, move less than one foot in a day. A box turtle travels about ten feet per minute, while a snail travels five inches per hour. A chimney swift flies almost ninety miles per hour. This is the fastest speed recorded for any living creature. A hydroplane skims across the top of the water at nearly 300 miles an hour. Some racing cars travel more than 500 miles per hour. The wind in a tornado may move at 600 miles per hour but sound waves are faster with a speed of up to 740 miles per hour. The Earth moves around the sun at 67,000 miles per hour. At 186,000 miles per second, light is faster! Science has yet to discover anything that would surpass this speed.",
        "type": "post test",
        "gradeLevel": "Grade 6",
        "set": "Set C",
        "quizzes": [
            {
                "question": "Which living creature has the highest recorded speed?",
                "options": ["a box turtle", "light waves", "sound waves", "a chimney swift"],
                "correctAnswer": "a chimney swift"
            },
            {
                "question": "Among the following, which has the slowest rate of movement?",
                "options": ["a snail", "a glacier", "a box turtle", "a chimney swift"],
                "correctAnswer": "a glacier"
            },
            {
                "question": "What does this statement mean? “Science has yet to discover anything that would surpass the speed of light.”",
                "options": [
                    "Someday, something faster than light will be discovered.",
                    "Of all moving objects, only light waves will never slow down.",
                    "Among all things, light waves will always have the fastest speed.",
                    "Of all that has been observed, light waves have the fastest speed."
                ],
                "correctAnswer": "Of all that has been observed, light waves have the fastest speed."
            },
            {
                "question": "Which among these statements is true?",
                "options": [
                    "A box turtle is faster than a snail.",
                    "A snail is faster than a box turtle.",
                    "A hydroplane is slower than a glacier.",
                    "A glacier is faster than a hydroplane."
                ],
                "correctAnswer": "A box turtle is faster than a snail."
            },
            {
                "question": "Which among these statements is NOT supported by the selection?",
                "options": [
                    "Tornadoes are around double the speed of a hydroplane.",
                    "Sound waves are about two times the speed of light waves.",
                    "A hydroplane is about half the speed of the wind in a tornado.",
                    "The speed of light is faster than the speed of the earth’s rotation."
                ],
                "correctAnswer": "Sound waves are about two times the speed of light waves."
            },
            {
                "question": "“Science has yet to discover anything that would surpass this speed.” The synonym of surpass is __________.",
                "options": ["equal", "reduce", "accede", "exceed"],
                "correctAnswer": "exceed"
            },
            {
                "question": "Which among these statements is an opinion?",
                "options": [
                    "Sound waves move faster than the wind.",
                    "There will never be anything faster than light.",
                    "Many things differ in their rates of movement.",
                    "The earth orbits the sun at 67,000 miles per hour."
                ],
                "correctAnswer": "There will never be anything faster than light."
            },
            {
                "question": "Which sentence states the main idea of the selection?",
                "options": [
                    "A hydroplane skims across the top of the water at nearly 300 miles an hour.",
                    "There are many things found around us that move at different rates.",
                    "The chimney swift has the fastest recorded speed among living things.",
                    "The Earth orbits the sun at 67,000 miles per hour but light moves faster."
                ],
                "correctAnswer": "There are many things found around us that move at different rates."
            }
        ]
    },
    {
        "title": "Air Currents",
        "content": "Wind is the natural movement of the air from one place to another. It affects the climate of a place. There are three major air streams that greatly affect our climate. From November to February, mornings are colder because of the northeast monsoon wind. It blows from Siberia which is a very frigid place. It brings along temperature and rain that make us shiver. The wind from June to October, is warm and humid. During this time, the western section of our country experiences strong rains brought about by the southwest monsoon wind blowing from Australia. From March to early May, trade winds coming from the east or northeast reach the Philippines. It brings rains to the eastern part of our country. Trade winds are warm and moist and bring hot temperature with little rain. Isn’t it amazing that each one of these air streams brings some amount of rain to the Philippines?",
        "type": "post test",
        "gradeLevel": "Grade 7",
        "set": "Set C",
        "quizzes": [
            {
                "question": "The northeast monsoon wind blowing from Siberia causes _______.",
                "options": ["heavy rains", "windy days", "hot temperature", "cold temperature"],
                "correctAnswer": "cold temperature"
            },
            {
                "question": "Which of the following statements is true about the wind?",
                "options": ["The wind attracts tourists to visit a place.", "The wind affects the climate of a place.", "The wind always comes from one direction.", "The wind moves at select times of the year."],
                "correctAnswer": "The wind affects the climate of a place."
            },
            {
                "question": "Siberia is a very frigid place. What is an antonym for the word frigid?",
                "options": ["very moist", "very cold", "very hot", "very windy"],
                "correctAnswer": "very cold"
            },
            {
                "question": "You are going on a vacation at your cousin’s province in the eastern part of the country in March. What type of clothes should you bring?",
                "options": ["new", "thin", "thick", "modern"],
                "correctAnswer": "thin"
            },
            {
                "question": "Among these different air streams in the Philippines, which is the most appropriate for wearing very heavy clothes?",
                "options": ["trade winds", "easterly winds", "southeast monsoons", "northeast monsoons"],
                "correctAnswer": "northeast monsoons"
            },
            {
                "question": "Which among these statements is backed up by the selection?",
                "options": ["Northeast monsoons account for strong rains during the June opening of classes.", "Southwest monsoons bring some amount of rain to the country even in May.", "Eastern portions of the country experience strong rains from June to October.", "Western portions of the country experience strong rains from June to October."],
                "correctAnswer": "Western portions of the country experience strong rains from June to October."
            },
            {
                "question": "What device did the author use to develop the selection?",
                "options": ["examples", "cause and effect", "a series of events", "problem and solution"],
                "correctAnswer": "cause and effect"
            },
            {
                "question": "Which could be another title of the selection?",
                "options": ["Different Causes of Heavy Rains", "How Air Streams Affect Climate", "Northwest and Southwest Monsoons", "Hot and Cold Temperature in the Country"],
                "correctAnswer": "How Air Streams Affect Climate"
            }
        ]
    },
    {
        "title": "Where the Pets Sat",
        "content": "Mat is a cat. Mat sat on a hat. Jig is a pig. Jig sat on a wig. Len is a hen. Len did not sit on a hat or a wig. Len sat on ten eggs!",
        "type": "post test",
        "gradeLevel": "Grade 2",
        "set": "Set D",
        "quizzes": [
            {
                "question": "Where did the pig sit?",
                "options": ["on a hat", "on a wig", "on ten eggs"],
                "correctAnswer": "on a wig"
            },
            {
                "question": "What did the cat do?",
                "options": ["sat on eggs", "sat on a wig", "sat on a hat"],
                "correctAnswer": "sat on a hat"
            },
            {
                "question": "Which animal sits on something that can break?",
                "options": ["the hen", "the cat", "the pig"],
                "correctAnswer": "the hen"
            },
            {
                "question": "Why was it good for Len to sit on the eggs?",
                "options": ["so the eggs will not get lost", "so the eggs will hatch into chicks", "so the eggs will stay on the nest"],
                "correctAnswer": "so the eggs will hatch into chicks"
            },
            {
                "question": "Which of the following will happen last?",
                "options": ["The hen will lay eggs.", "The hen will sit on the eggs.", "The hen will have chicks."],
                "correctAnswer": "The hen will have chicks."
            }
        ]
    },
    {
        "title": "In the Park",
        "content": "Today, Sam and Ria will go to the park. What will they do there? They will sit on the grass and look at some bugs. They will look at the holes that the worms have just dug. That is where they will stay on this warm summer day. But they must leave the park before it gets dark.",
        "type": "post test",
        "gradeLevel": "Grade 3",
        "set": "Set D",
        "quizzes": [
            {
                "question": "Who will go to the park?",
                "options": ["Cam and Mia", "Dan and Iya", "Sam and Ria"],
                "correctAnswer": "Sam and Ria"
            },
            {
                "question": "What will the children do in the park?",
                "options": ["play with other children", "observe the insects", "watch the clouds"],
                "correctAnswer": "observe the insects"
            },
            {
                "question": "Why are the children not in school?",
                "options": ["It is their Christmas break.", "They are on a class field trip.", "It is their summer vacation."],
                "correctAnswer": "It is their summer vacation."
            },
            {
                "question": "When should the children leave the park?",
                "options": ["night time", "lunch time", "late afternoon"],
                "correctAnswer": "late afternoon"
            },
            {
                "question": "What else can the two children do at the park?",
                "options": ["play with others", "watch the stars", "eat their dinner"],
                "correctAnswer": "play with others"
            },
            {
                "question": "What is the message of the story?",
                "options": ["There are children who do not like the park.", "There are people who tell others to visit the park.", "There are many things to see and do at the park."],
                "correctAnswer": "There are many things to see and do at the park."
            }
        ]
    },
    {
    "title": "On Market Day",
    "content": "Every Saturday, Manuel goes to market with his father, Mang Ador. They always pass by Aling Juaning’s stall to buy meat. They go to Mang Tinoy’s for fresh vegetables. They also visit Aling Tita’s seafood section. Whenever Mang Ador buys something, Manuel always tries to predict what his father will cook for lunch. Today Mang Ador bought tamarind, tomatoes, string beans, radish, and shrimp. “I know what we will have for lunch,” says Manuel happily. Can you guess it, too?",
    "type": "post test",
    "gradeLevel": "Grade 4",
    "set": "SET D",
    "quizzes": [
        {
            "question": "Who is the father in the selection?",
            "options": ["Ador", "Tinoy", "Manuel"],
            "correctAnswer": "Ador"
        },
        {
            "question": "Which stall do the father and son get their fish from?",
            "options": ["Mang Tinoy’s stall", "Aling Tita’s stall", "Aling Juaning’s stall"],
            "correctAnswer": "Aling Tita’s stall"
        },
        {
            "question": "What section of the market do the father and son always go to?",
            "options": ["fish, meat, and fruits sections", "vegetable, fish, and fruit sections", "vegetable, seafood, and meat sections"],
            "correctAnswer": "vegetable, seafood, and meat sections"
        },
        {
            "question": "In the story, the boy tries to predict what they will have for lunch. When one tries to predict, one tries to ____.",
            "options": ["ask", "hear", "guess"],
            "correctAnswer": "guess"
        },
        {
            "question": "The boy in the story shows us that a person can find out what his family will have for lunch by ____________.",
            "options": ["looking at what his father buys from the market", "asking his mother what she thinks his father will cook", "smelling the scents in the kitchen as his father cooks"],
            "correctAnswer": "looking at what his father buys from the market"
        },
        {
            "question": "What do you think does Manuel say on their way to the market?",
            "options": ["“I’m tired.”", "“I’m excited.”", "“I‘m nervous.”"],
            "correctAnswer": "“I’m excited.”"
        }
    ]
  },
  {
    "title": "The Legend of the Firefly",
    "content": "There was a time when young and old stars could talk to Bathala. One day, the young stars learned that they become part of a black hole when they grow old. The young stars feared losing their light. They asked Bathala for help. “I have a solution. But you have to give up a lot,” said Bathala. “You need to leave the heavens and live on land.” Some of the younger stars agreed. On a dark night, you might chance upon these stars. They have turned into tiny twinkling bugs whose tails flicker as they fly from place to place.",
    "type": "post test",
    "gradeLevel": "Grade 5",
    "set": "SET D",
    "quizzes": [
        {
            "question": "What did the younger stars fear?",
            "options": ["asking for help", "becoming insects", "losing their light", "leaving the heavens"],
            "correctAnswer": "losing their light"
        },
        {
            "question": "What was Bathala’s solution to the younger stars’ problem?",
            "options": ["He will make them young forever.", "He will turn them into bugs with lights.", "He will give them their light for eternity.", "He will give them a new life in the heavens."],
            "correctAnswer": "He will turn them into bugs with lights."
        },
        {
            "question": "“One might chance upon these stars on a very dark night.” Which statement below means the same thing?",
            "options": ["One will always see these stars on a very dark night.", "One will never see the stars on a very dark night.", "One will surely see these stars on a very dark night.", "One will possibly see these stars on a very dark night."],
            "correctAnswer": "One will possibly see these stars on a very dark night."
        },
        {
            "question": "The story is a legend. This means that _______________.",
            "options": ["It is a real story about a person’s life.", "It is a story which could really happen.", "It is a story about where things came from.", "It is a story where there are talking animals."],
            "correctAnswer": "It is a story about where things came from."
        },
        {
            "question": "According to the selection, what is a firefly?",
            "options": ["a bug that wants so much to be a star", "an old star that already lost its energy", "an insect that died and went to heaven", "a young star that became a glowing insect"],
            "correctAnswer": "a young star that became a glowing insect"
        },
        {
            "question": "Which statement is NOT explicitly stated in the given selection? Fireflies are ___________________.",
            "options": ["young stars that did not want to lose their energy", "twinkling bugs that used to be fearful young stars", "insects with chemicals that make their bodies glow", "young stars that once lived in the heavens with old stars"],
            "correctAnswer": "insects with chemicals that make their bodies glow"
        },
        {
            "question": "Why did Bathala say “you would have to give up much” to the young stars?",
            "options": ["Life on earth will give them less light.", "The young stars will give up their lives.", "The young stars will not be happy on earth.", "Life was better in the heavens than on earth."],
            "correctAnswer": "Life was better in the heavens than on earth."
        }
    ]
  },
  {
    "title": "Flying Rocks",
    "content": "There are rocks in our Solar System that never flocked together to form planets. Larger ones called asteroids gather in the Asteroid Belt, a strip found between Mars and Jupiter. Some asteroids don’t move along this belt but have paths that bring them close to the earth. These are called Apollo Asteroids. There may be half a million asteroids whose diameters are bigger than one kilometer. The largest asteroid is over 1000 kilometers across. It is speculated that many asteroids were once larger but they collided with each other and became small fragments. Unlike asteroids, meteoroids are small rocky bodies, that are scattered in space and do not orbit the sun. They cross the Earth’s orbit and are often seen burning up in the Earth’s atmosphere at night. The faint flashes of light they make are called shooting stars.",
    "type": "post test",
    "gradeLevel": "Grade 6",
    "set": "SET D",
    "quizzes": [
        {
            "question": "What are asteroids?",
            "options": ["Large fragments of rock in the Solar System", "Large fragments of rock that circle the moon", "Small fragments of rock that do not circle the sun", "Small fragments of rock that do not circle the planets"],
            "correctAnswer": "Large fragments of rock in the Solar System"
        },
        {
            "question": "What are meteoroids?",
            "options": ["Large fragments of rock that circle the sun", "Large fragments of rock that circle the planets", "Small bits of rock that do not circle the sun", "Small bits of rock that do not cross the planets’ orbits"],
            "correctAnswer": "Small bits of rock that do not circle the sun"
        },
        {
            "question": "Which among the following statements is NOT true?",
            "options": ["Some asteroids move close to the earth.", "Large rocks flock together in the Asteroid Belt.", "All rocks in our Solar System have formed planets.", "The Asteroid Belt is found between Mars and Jupiter."],
            "correctAnswer": "All rocks in our Solar System have formed planets."
        },
        {
            "question": "“It is speculated that many asteroids were once larger.” What does the word speculated mean?",
            "options": ["written", "guessed", "confirmed", "questioned"],
            "correctAnswer": "guessed"
        },
        {
            "question": "What is a possible reason behind the fact that asteroids are not anymore as large as they were first thought to be?",
            "options": ["They could have shrunk when they got closer to the sun.", "They could have hit one another and broken into pieces.", "They could have burned up and eventually become smaller.", "They could have rammed into some planet and broken apart."],
            "correctAnswer": "They could have hit one another and broken into pieces."
        },
        {
            "question": "Which of the following statements is TRUE of asteroids and meteoroids?",
            "options": ["Both asteroids and meteoroids can be seen in a belt of rocks between Jupiter and Mars.", "Both asteroids and meteoroids circle the Earth and can be seen as faint flashes of light.", "Both asteroids and meteoroids are composed of rocky particles found in the Solar System.", "Both asteroids and meteoroids are scattered randomly across in space and do not orbit the sun."],
            "correctAnswer": "Both asteroids and meteoroids are composed of rocky particles found in the Solar System."
        },
        {
            "question": "Many asteroids must have collided with one another. What is a synonym of the word “collided?”",
            "options": ["trapped into", "crashed into", "converged with", "connected with"],
            "correctAnswer": "crashed into"
        },
        {
            "question": "If you see faint flashes of light in the night sky, which of the following could have happened?",
            "options": ["Flames shoot up from the sun and come closer to the earth.", "Meteoroids have just crossed the earth’s orbit and burned up.", "Meteoroids have just crossed paths with the sun and burned up.", "There are moments when the earth orbits a lot closer to the sun."],
            "correctAnswer": "Meteoroids have just crossed the earth’s orbit and burned up."
        }
    ]
  },
  {
    "title": "Ecosystems",
    "content": "Ecosystems consist of living and non-living organisms in an area. These include plants, animals, microbes, and elements like soil, water, and air. The living organisms depend on both living and non-living aspects of an ecosystem. An ecosystem can be as small as a puddle or as big as an ocean. It is a very delicate balance, with these life forms sustaining one another. Disruptions to an ecosystem may prove disastrous to all its organisms. When a new plant or animal is suddenly placed in an ecosystem, it will surely compete with the original inhabitants for resources. This stranger may even push out the natural organisms, causing them to be extinct. The organisms that depended on the extinct organisms will definitely be affected. The balance in ecosystems have been unsettled by natural disasters such as fires, floods, storms, and volcanic eruptions. However, in recent years and ironically, in the name of progress, human activity has affected many ecosystems around the world.",
    "type": "post test",
    "gradeLevel": "Grade 7",
    "set": "SET D",
    "quizzes": [
        {
            "question": "Which among the following is NOT a good description for an ecosystem?",
            "options": ["animals and plants relying on each other to survive", "a place where people are friendly to the environment", "a biological community where organisms affect each other", "a variety of living and non-living things in a particular area"],
            "correctAnswer": "a place where people are friendly to the environment"
        },
        {
            "question": "Why is an ecosystem considered to be a delicate balance?",
            "options": ["There are big ecosystems and small ecosystems that have to be balanced.", "Not all ecosystems weigh the same so their weight needs to be distributed.", "A change in an ecosystem can have tremendous effects on all its organisms.", "Different organisms always have equal importance in any given ecosystem."],
            "correctAnswer": "A change in an ecosystem can have tremendous effects on all its organisms."
        },
        {
            "question": "Which of the following is NOT one of the natural disasters that have caused ecosystems to be unsettled?",
            "options": ["fires", "floods", "storms", "humans"],
            "correctAnswer": "humans"
        },
        {
            "question": "Based on the selection, which of the following is true about human progress and ecosystems?",
            "options": ["Human progress sometimes causes ecosystems to suffer.", "Human activity promotes the development of ecosystems.", "Human activity helps find solutions to ecological problems.", "Human progress causes different ecosystems to be progressive."],
            "correctAnswer": "Human progress sometimes causes ecosystems to suffer."
        },
        {
            "question": "According to the selection, a new organism introduced in an ecosystem can have an effect on an original inhabitant when _______________.",
            "options": ["it fights with and eventually eats the original inhabitant", "it consumes resources intended for the original inhabitant", "it makes the original inhabitant feel strange in the ecosystem", "it contributes to disasters that upset the balance in the system"],
            "correctAnswer": "it consumes resources intended for the original inhabitant"
        },
        {
            "question": "What should human beings do in order to maintain the balance in different ecosystems?",
            "options": ["Cut down a lot of trees so that there is more space for animals to live in.", "Take corals from the sea so that fish would have more freedom to swim.", "Plant more trees in order to replace those that have been cut down.", "Catch a lot of tuna so that nothing will eat the mackerel or the small fish."],
            "correctAnswer": "Plant more trees in order to replace those that have been cut down."
        },
        {
            "question": "The diagram below shows an ocean ecosystem. The arrows point to the food source of the succeeding organism. If a new organism is introduced into the system and it eats the shrimplike creatures, how will this indirectly affect the mackerel?",
            "options": ["The mackerel will have no more shrimplike creatures to eat.", "The mackerel will still be eaten by the tuna fish as it continues to consume the small fish.", "The mackerel will be eaten by the small fish which now has to look for a new food source.", "The mackerel might lose its food since without a food source, the small fish could die."],
            "correctAnswer": "The mackerel might lose its food since without a food source, the small fish could die."
        },
        {
            "question": "Using the same diagram, which of the following statements is FALSE?",
            "options": ["The small fish depends solely on shrimplike creatures for food.", "The tuna fish depends solely on the mackerel as its food source.", "The large shark depends solely on the tuna fish as its food source.", "The shrimplike creatures depend solely on one-celled life for food."],
            "correctAnswer": "The tuna fish depends solely on the mackerel as its food source."
        }
      ]
    }
  ]


  
  const batch = db.batch();

  passages.forEach((passage) => {
    const docRef = db.collection("Stories").doc(); 
    batch.set(docRef, {
      title: passage.title,
      content: passage.content,
      type: passage.type,
      gradeLevel: passage.gradeLevel,
      set: passage.set,
      isDefault: true // Mark this as default data
    });

    const questions = passage.quizzes.map((quiz) => {
      const answers = {};
      quiz.options.forEach((option, index) => {
        const key = String.fromCharCode(65 + index); // A, B, C, etc.
        answers[key] = option;
      });

      const correctAnswerKey = Object.keys(answers).find(key => answers[key] === quiz.correctAnswer);

      if (!correctAnswerKey) {
        throw new Error(`Correct answer "${quiz.correctAnswer}" not found in options for question: "${quiz.question}"`);
      }

      return {
        question: quiz.question,
        answers: answers,
        correctAnswer: correctAnswerKey
      };
    });

    const quizRef = db.collection("Quizzes").doc();
    batch.set(quizRef, {
      title: passage.title,
      type: passage.type,
      gradeLevel: passage.gradeLevel,
      set: passage.set,
      isDefault: true, // Mark this as default data
      questions: questions // Store all questions under the title
    });
  });

  await batch.commit();
  console.log("Bulk upload of passages and quizzes completed.");
}

// Call the function to perform the bulk upload
bulkUpload().catch(console.error);