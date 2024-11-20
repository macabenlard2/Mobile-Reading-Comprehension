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
        "title": "Pam’s Cat",
        "content": "Pam has a cat.\nIt is on the bed.\nIt can nap. It can sit.\n“Oh no!” says Pam.\n“The cat fell off the bed!”\nIs the cat sad?\nNo. It is on the mat.",
        "type": "pretest",
        "gradeLevel": "Grade 2",
        "set": "Set A",
        "quizzes": [
            {
                "question": "Who has a pet?",
                "options": ["Pat", "Pam", "Paz"],
                "correctAnswer": "Pam"
            },
            {
                "question": "What is her pet?",
                "options": ["dog", "pig", "cat"],
                "correctAnswer": "cat"
            },
            {
                "question": "Why did Pam say “Oh no!”?",
                "options": ["She was mad.", "She was happy.", "She was worried."],
                "correctAnswer": "She was worried."
            },
            {
                "question": "Why did she feel this way?",
                "options": ["Her cat can do tricks.", "Her cat made a mess.", "Her cat might be hurt."],
                "correctAnswer": "Her cat might be hurt."
            },
            {
                "question": "How do we know that the cat is ok?",
                "options": ["It is on the bed.", "It is on the mat.", "It has a rat."],
                "correctAnswer": "It is on the mat."
            }
        ]
    },
    {
        "title": "Summer Fun",
        "content": "“Let’s have some fun this summer,” says Leo.\n“Let’s swim in the river,” says Lina.\n“Let’s get some star apples from the tree,” says Leo.\n“Let’s pick flowers,” says Lina.\n“That is so much fun!” says Mama.\n“But can you help me dust the shelves too?”\n“Yes, we can Mama,” they say.\n“Helping can be fun too!”",
        "type": "pretest",
        "gradeLevel": "Grade 3",
        "set": "Set A",
        "quizzes": [
            {
                "question": "Who were talking to each other?",
                "options": ["Lita and Lito", "Lina and Lino", "Lina and Leo"],
                "correctAnswer": "Lina and Leo"
            },
            {
                "question": "What were they talking about?",
                "options": ["what to do during the summer", "what to have during the summer", "what to wear during the summer"],
                "correctAnswer": "what to do during the summer"
            },
            {
                "question": "The children in the story could be _______",
                "options": ["brother and sister", "neighbors", "cousins"],
                "correctAnswer": "brother and sister"
            },
            {
                "question": "Which of these will they do if they are hungry?",
                "options": ["pick flowers", "pick guavas", "go swimming"],
                "correctAnswer": "pick guavas"
            },
            {
                "question": "Doing something 'fun' means ______________.",
                "options": ["doing something in the summer", "doing something in the house", "doing something that we like"],
                "correctAnswer": "doing something that we like"
            },
            {
                "question": "Which these is the best example of being helpful?",
                "options": ["picking flowers", "cleaning up", "swimming"],
                "correctAnswer": "cleaning up"
            }
        ]
    },
    {
        "title": "Get Up, Jacky!",
        "content": "“Ring! Ring!” rang the clock.\nBut Jacky did not get up.\n“Wake up, Jacky! Time for school,” yelled Mom.\nAnd yet Jacky did not get up.\n“Beep! Beep!” honked the horn of the bus.\nJacky still laid snug on the bed.\nSuddenly, a rooster crowed out loud\nand sat on the window sill.\nJacky got up and said with cheer,\n“I will get up now. I will!”",
        "type": "pretest",
        "gradeLevel": "Grade 4",
        "set": "Set A",
        "quizzes": [
            {
                "question": "Who is the main character in our story?",
                "options": ["Jock", "Jicky", "Jacky"],
                "correctAnswer": "Jacky"
            },
            {
                "question": "Why did the main character need to wake up early?",
                "options": ["to get to school on time", "to get to work on time", "to get to bed on time"],
                "correctAnswer": "to get to school on time"
            },
            {
                "question": "What woke the character up?",
                "options": ["the ringing of the alarm clock", "the crowing of the rooster", "Mom’s yelling"],
                "correctAnswer": "the crowing of the rooster"
            },
            {
                "question": "What did the character think as he/she 'laid snug' on the bed?",
                "options": ["“I do not want to get up yet.”", "“I do not want to be late today.”", "“I want to be extra early today.”"],
                "correctAnswer": "“I do not want to get up yet.”"
            },
            {
                "question": "What does it mean to say something 'with cheer'?",
                "options": ["We say it sadly.", "We say it happily.", "We say it with fear."],
                "correctAnswer": "We say it happily."
            },
            {
                "question": "Which of these statements fits the story?",
                "options": ["Jacky liked being woken up by a clock.", "Jacky liked being woken up by a bus horn.", "Jacky liked being woken up by a rooster."],
                "correctAnswer": "Jacky liked being woken up by a rooster."
            }
        ]
    },
    {
        "title": "Frog’s Lunch",
        "content": "One day, a frog sat on a lily pad, still as a rock.\nA fish swam by.\n“Hello, Mr. Frog! What are you waiting for?”\n“I am waiting for my lunch,” said the frog.\n“Oh, good luck!” said the fish and swam away.\nThen, a duck waddled by.\n“Hello, Mr. Frog! What are you waiting for?”\n“I am waiting for my lunch,” said the frog.\n“Oh, good luck!” said the duck and waddled away.\nThen a bug came buzzing by.\n“Hello, Mr. Frog! What are you doing?” asked the bug.\n“I’m having my lunch! Slurp!” said the frog.\nMr. Frog smiled.",
        "type": "pretest",
        "gradeLevel": "Grade 5",
        "set": "Set A",
        "quizzes": [
            {
                "question": "Who is the main character in the story?",
                "options": ["the bug", "the duck", "the fish", "the frog"],
                "correctAnswer": "the frog"
            },
            {
                "question": "What was he doing?",
                "options": ["resting on a lily pad", "chatting with a bug", "hunting for his food", "waiting for the rain"],
                "correctAnswer": "hunting for his food"
            },
            {
                "question": "In what way was he able to get his lunch?",
                "options": ["He was able to fool the fish.", "He was able to fool the duck.", "He was able to fool the rock.", "He was able to fool the bug."],
                "correctAnswer": "He was able to fool the bug."
            },
            {
                "question": "Why should the frog be “still as a rock?”",
                "options": ["so that he will not scare the other animals away", "so that he can catch his lunch", "so that the other animals will think he is friendly", "so that the fish will say nice things about him"],
                "correctAnswer": "so that he can catch his lunch"
            },
            {
                "question": "Which of these words describe the duck?",
                "options": ["patient", "eager", "curious", "careful"],
                "correctAnswer": "curious"
            },
            {
                "question": "Which of these words describe Mr. Frog?",
                "options": ["patient", "eager", "curious", "careful"],
                "correctAnswer": "patient"
            },
            {
                "question": "Which of these characteristics would have helped the bug?",
                "options": ["being patient", "being eager", "being curious", "being careful"],
                "correctAnswer": "being careful"
            }
        ]
    },
    {
        "title": "Yawning",
        "content": "What makes us yawn? Yawning is something that we\ncannot control. Even in the mother’s womb, eleven-week-old\nbabies have been observed to yawn. But why do we do it?\nOne popular explanation for yawning is that a person may be\ntired or bored. Although many believe this to be true, it cannot\nexplain why athletes yawn before an event or why dogs yawn\nbefore an attack.\nIt is said that yawning is caused by a lack of oxygen and\nexcess carbon dioxide. A good example of this is when we yawn\nin groups. We yawn because we are competing for air.\nOthers even believe that we yawn to cool our brains off.\nCool brains allow us to think more clearly so yawning is said to\nhelp us become more alert.",
        "type": "pretest",
        "gradeLevel": "Grade 6",
        "set": "Set A",
        "quizzes": [
            {
                "question": "What is a fact about yawning?",
                "options": ["It is something we cannot control.", "It is something only humans do", "It is a result of boredom.", "It happens after birth."],
                "correctAnswer": "It is something we cannot control."
            },
            {
                "question": "Which of the following might make us yawn?",
                "options": ["reading a book", "being in a crowded room", "being around plants", "being in a small air-conditioned car"],
                "correctAnswer": "being in a crowded room"
            },
            {
                "question": "What does the word 'involuntary' mean?",
                "options": ["expected", "unexpected", "within control", "uncontrollable"],
                "correctAnswer": "uncontrollable"
            },
            {
                "question": "Which of the following may be a benefit of yawning?",
                "options": ["It warns us of possible attacks by dogs.", "It provides us the carbon dioxide we need.", "It cools our brains.", "It balances the amount of oxygen and carbon dioxide."],
                "correctAnswer": "It cools our brains."
            },
            {
                "question": "According to the selection, what is most likely to happen after we yawn?",
                "options": ["We will become more alert.", "We will be less tired.", "We will be less sleepy.", "We will be calmer."],
                "correctAnswer": "We will become more alert."
            },
            {
                "question": "In the selection, how is the word 'compete' used in the phrase 'competing for air?'",
                "options": ["struggling to take in some air", "arguing about breathing", "battling it out for oxygen", "racing to breathe more air"],
                "correctAnswer": "struggling to take in some air"
            },
            {
                "question": "Which of the following shows evidence that 'yawning' is 'competing for air?'",
                "options": ["The passengers in an elevator yawned.", "Several people yawned while picnicking at an open field.", "Two people yawned inside a room with air-conditioning.", "Three students yawned in a big empty room."],
                "correctAnswer": "The passengers in an elevator yawned."
            },
            {
                "question": "Which of the following is the best response when we see a person/animal yawn?",
                "options": ["Have the person eat a food item that is a good source of energy.", "Change the topic of conversation to a more interesting one.", "Turn on an electric fan or source of ventilation.", "Run away to avoid being attacked."],
                "correctAnswer": "Turn on an electric fan or source of ventilation."
            }
        ]
    },
    {
        "title": "Dark Chocolate",
        "content": "Dark chocolate finds its way into the best ice creams,\nbiscuits and cakes. Although eating chocolate usually comes\nwith a warning that it is fattening, it is also believed by some\nto have magical and medicinal effects. In fact, cacao trees are\nsometimes called Theobroma cacao which means “food of the\ngods.”\nDark chocolate has been found out to be helpful in small\nquantities. One of its benefits is that it has some of the most\nimportant minerals and vitamins that people need. It has\nantioxidants that help protect the heart. Another important\nbenefit is that the fat content of chocolate does not raise the\nlevel of cholesterol in the blood stream. A third benefit is that it\nhelps address respiratory problems. Also, it has been found out\nto help ease coughs and respiratory concerns. Finally, chocolate\nincreases serotonin levels in the brain. This is what gives us a\nfeeling of well-being.",
        "type": "pretest",
        "gradeLevel": "Grade 7",
        "set": "Set A",
        "quizzes": [
            {
                "question": "Why was chocolate called Theobroma cacao?",
                "options": ["It is considered to be fattening food", "It is a magical tree", "It is a medicinal candy", "It is food of the gods."],
                "correctAnswer": "It is food of the gods."
            },
            {
                "question": "Which statement is true?",
                "options": ["All chocolates have medicinal properties.", "In small doses, dark chocolate is fattening.", "Dark chocolate has minerals and vitamins.", "Chocolate raises the level of cholesterol."],
                "correctAnswer": "Dark chocolate has minerals and vitamins."
            },
            {
                "question": "What is found in dark chocolate that will help encourage its consumption?",
                "options": ["antioxidants", "sugar", "fats", "milk"],
                "correctAnswer": "antioxidants"
            },
            {
                "question": "After we eat chocolate, which of these is responsible for making us feel good?",
                "options": ["cacao", "theobroma", "serotonin", "antioxidants"],
                "correctAnswer": "serotonin"
            },
            {
                "question": "If a person coughs and is asked to have some chocolate, why would this be good advice?",
                "options": ["Dark chocolate helps respiratory problems.", "Dark chocolate helps circulation.", "Dark chocolate does not raise the level of cholesterol.", "Dark chocolate has vitamins and minerals."],
                "correctAnswer": "Dark chocolate helps respiratory problems."
            },
            {
                "question": "Which of the following body systems does not directly benefit from the consumption of dark chocolate?",
                "options": ["Circulatory system", "Respiratory system", "Excretory system.", "Nervous system"],
                "correctAnswer": "Excretory system."
            },
            {
                "question": "Which important fact shows that dark chocolate may be safe for the heart?",
                "options": ["It may ease coughs.", "It helps address respiratory problems.", "It does not raise the level of cholesterol.", "In small quantities, dark chocolate has been said to be medicinal."],
                "correctAnswer": "It does not raise the level of cholesterol."
            },
            {
                "question": "What does 'address' mean in the second paragraph?",
                "options": ["to locate", "to identify", "to deal with", "to recognize"],
                "correctAnswer": "to deal with"
            }
        ]
    },
    {
        "title": "A Hot Day",
        "content": "The sun is up.\n“Is it a hot day, Matt?” asks Sal.\n“Yes, it is,” says Matt.\nSal gets her fan.\nMatt gets his hat.\nSal and Matt go out to play.\nSal and Matt have fun.",
        "type": "pretest",
        "gradeLevel": "Grade 2",
        "set": "Set B",
        "quizzes": [
            {
                "question": "Who are the children in the story?",
                "options": ["Sam and Matt", "Sal and Max", "Matt and Sal"],
                "correctAnswer": "Matt and Sal"
            },
            {
                "question": "What kind of day was it?",
                "options": ["a sunny day", "a cloudy day", "a rainy day"],
                "correctAnswer": "a sunny day"
            },
            {
                "question": "What did the little girl do so that she will not feel hot?",
                "options": ["She stayed inside.", "She got a hat.", "She got a fan."],
                "correctAnswer": "She got a fan."
            },
            {
                "question": "What did the little boy do so that he will not feel hot?",
                "options": ["He stayed inside.", "He got a hat.", "He got a fan."],
                "correctAnswer": "He got a hat."
            },
            {
                "question": "What is the message of the story?",
                "options": ["We can have fun on a hot day.", "We can have fun on a cool day.", "We can have fun on a cloudy day."],
                "correctAnswer": "We can have fun on a hot day."
            }
        ]
    },
    {
        "title": "A Rainy Day",
        "content": "Nina and Ria are looking out the window.\n“I do not like getting wet in the rain,” says Nina.\n“What can we do?” asks Ria.\n“We can play house,” says Nina.\n“Or we can play tag,” says Ria.\n“Okay, let’s play tag. You’re it!” says Nina.\nNina runs from Ria and bumps a lamp.\n“Oh no!” says Nina.\n“We must not play tag in the house.”",
        "type": "pretest",
        "gradeLevel": "Grade 3",
        "set": "Set B",
        "quizzes": [
            {
                "question": "What is it that Ria does not like?",
                "options": ["playing tag", "playing house", "getting wet in the rain"],
                "correctAnswer": "getting wet in the rain"
            },
            {
                "question": "What does Nina want to do?",
                "options": ["play tag", "play house", "get wet in the rain"],
                "correctAnswer": "play house"
            },
            {
                "question": "Who wants to play tag?",
                "options": ["Ria", "Nina", "Ria and Nina"],
                "correctAnswer": "Ria and Nina"
            },
            {
                "question": "What is 'tag?'",
                "options": ["a card game", "a video game", "a running game"],
                "correctAnswer": "a running game"
            },
            {
                "question": "Why wasn’t it a good idea to play tag in the house?",
                "options": ["Something might break", "Someone might get tired", "Something might get lost"],
                "correctAnswer": "Something might break"
            },
            {
                "question": "Which word tells what Ria and Nina should be?",
                "options": ["careless", "careful", "curious"],
                "correctAnswer": "careful"
            }
        ]
    },
    {
        "title": "Waiting for the Peddler",
        "content": "Mama was feeling sick.\n“Lisa, I cannot make you a snack,” she said.\n“Can you watch out for the peddler while I rest?”\n“Yes Mama,” Lisa answered.\nSoon, a man shouted, “Taho! Taho!”\nLisa ran. “Two cups please,” she said.\nLisa paid the man.\nShe got one cup of taho and gave the other to Mama.\n“Thank you, Lisa. I feel much better now,” said Mama.\n“You’re welcome, Mama!”",
        "type": "pretest",
        "gradeLevel": "Grade 4",
        "set": "Set B",
        "quizzes": [
            {
                "question": "What is it that Mama could NOT do?",
                "options": ["She could not go out.", "She could not make Lisa a snack.", "She could not wait for the peddler."],
                "correctAnswer": "She could not make Lisa a snack."
            },
            {
                "question": "Which of the following did NOT happen in the story?",
                "options": ["Lisa went out to buy taho.", "Lisa waited for the peddler.", "Lisa made a snack for Mama."],
                "correctAnswer": "Lisa made a snack for Mama."
            },
            {
                "question": "Which of the following words best describes Lisa?",
                "options": ["obedient", "resourceful", "hardworking"],
                "correctAnswer": "obedient"
            },
            {
                "question": "Which statement tells us what a peddler can do?",
                "options": ["A peddler sells snacks.", "A peddler visits the sick.", "A peddler brings medicine."],
                "correctAnswer": "A peddler sells snacks."
            },
            {
                "question": "When we 'watch out' for something or someone, we ____?",
                "options": ["look at something.", "wait for something", "go away from something"],
                "correctAnswer": "wait for something"
            },
            {
                "question": "Which statement best fits the story?",
                "options": ["It is good to visit the sick.", "It is best to buy from a peddler.", "Those who help us sometimes need help, too."],
                "correctAnswer": "Those who help us sometimes need help, too."
            }
        ]
    },
    {
        "title": "The Cow and the Carabao",
        "content": "Long ago, a farmer had a carabao and a cow. The\ncarabao was bigger but the cow worked just as hard.\nOne day the farmer said, “I can get more from my farm\nif my carabao works all day and my cow works all night.” This\nwent on for a month 'til finally, the carabao cried, “It is just too\nhot to work all day!” “Want to go for a swim?” asked the cow.\n“It will cool you off.” The carabao happily agreed. They went\noff without the farmer’s consent.\nBefore swimming, they hung their skins on a tree branch.\nBut it wasn’t long till the farmer went looking for them. Upon\nseeing the farmer, they rushed to put on their skins. In their\nrush, the carabao had worn the cow’s skin and the cow had\nworn the carabao’s skin.\nFrom then on, cows have sagging skin while carabaos\nhave tight skin.",
        "type": "pretest",
        "gradeLevel": "Grade 5",
        "set": "Set B",
        "quizzes": [
            {
                "question": "At the beginning of the story, what was one major difference between the cow and the carabao?",
                "options": ["The carabao was bigger than the cow.", "The cow had sagging skin while the carabao had tight skin.", "The carabao had sagging skin while the cow had tight skin.", "The carabao worked at night while the cow worked in the day."],
                "correctAnswer": "The carabao was bigger than the cow."
            },
            {
                "question": "What did the farmer decide one day?",
                "options": ["The cow and the carabao will work together.", "The cow and the carabao should not leave the farm.", "The carabao will work in the day while the cow will work at night.", "The cow will work in the day while the carabao will work at night."],
                "correctAnswer": "The carabao will work in the day while the cow will work at night."
            },
            {
                "question": "What word describes the farmer in the story?",
                "options": ["kind", "cruel", "grumpy", "hardworking"],
                "correctAnswer": "cruel"
            },
            {
                "question": "How did the farmer’s decision affect the cow and the carabao?",
                "options": ["They did not have time to rest.", "They hardly saw each other.", "They did not eat enough.", "They were always tired."],
                "correctAnswer": "They hardly saw each other."
            },
            {
                "question": "What does the phrase 'without consent' mean?",
                "options": ["did not have permission", "was not informed", "has not rested", "did not know"],
                "correctAnswer": "did not have permission"
            },
            {
                "question": "Which of the following events happened last?",
                "options": ["The carabao cried out that it was so hot.", "The cow and the carabao decided to swim.", "The farmer came while the animals were swimming.", "The cow and the carabao hurriedly put on their skins."],
                "correctAnswer": "The cow and the carabao hurriedly put on their skins."
            },
            {
                "question": "What kind of story is this?",
                "options": ["myth", "parable", "legend", "fairy tale"],
                "correctAnswer": "legend"
            }
        ]
    },    
    {
        "title": "Laughter",
        "content": "People love to laugh. We love it so much when there are\njokes, jobs, and shows that are made to make us laugh. Even\nthough laughing seems natural, not many species are able to do\nso.\nLaughing involves the performance of rhythmic, involuntary\nmovements, and the production of sounds. We are able to\nlaugh using fifteen facial muscles, our respiratory system, and\nsometimes even our tear ducts.\nWe are lucky that we are able to laugh because there is\nstrong evidence that laughter can help improve health. Laughter\nboosts the immune system and adds another layer of protection\nfrom disease. Since laughter also increases blood flow, it\nimproves the function of blood vessels that helps protect the\nheart. Laughter also relaxes the whole body by relieving tension\nand stress. Finally, laughter also brings out the body’s natural\nfeel-good chemicals that promote well-being.",
        "type": "pretest",
        "gradeLevel": "Grade 6",
        "set": "Set B",
        "quizzes": [
            {
                "question": "What is laughing?",
                "options": ["It is the voluntary reception of sounds.", "It is the voluntary production of sounds.", "It is the involuntary production of sounds.", "It is the voluntary use of our facial muscles."],
                "correctAnswer": "It is the involuntary production of sounds."
            },
            {
                "question": "What does the statement, 'There are jokes, jobs, and shows that are made to make us laugh,' imply in this selection?",
                "options": ["Laughter is something we have to work at.", "Comedy shows are good sources of income.", "Laughter is an important part of our life.", "Jokes and comedy shows are expensive ways to make us laugh."],
                "correctAnswer": "Laughter is an important part of our life."
            },
            {
                "question": "In what way does laughing prevent us from getting sick?",
                "options": ["It lets us have full use of our respiratory system.", "It helps boost our immune system.", "It allows us to use our tear ducts.", "It exercises our facial muscles."],
                "correctAnswer": "It helps boost our immune system."
            },
            {
                "question": "If laughter increases blood flow, which body system does it help?",
                "options": ["nervous system", "respiratory system", "excretory system", "circulatory system"],
                "correctAnswer": "circulatory system"
            },
            {
                "question": "Which word CANNOT be used to describe laughing?",
                "options": ["rhythmic", "voluntary", "uncontrollable", "functional"],
                "correctAnswer": "voluntary"
            },
            {
                "question": "Which of the following facts about laughter would be helpful to a hardworking secretary at a busy office?",
                "options": ["Laughter uses fifteen facial muscles.", "Laughter keeps tension and stress away.", "Laughter may help protect us from diseases.", "Laughter brings out the ‘feel good’ chemicals."],
                "correctAnswer": "Laughter keeps tension and stress away."
            },
            {
                "question": "Which of the following is the best title for the selection?",
                "options": ["Laughter is the answer.", "Laughter is the best medicine.", "Laughter is what sets humans apart.", "Laughter affects the human condition."],
                "correctAnswer": "Laughter is the best medicine."
            },
            {
                "question": "Which of the following would be the most ideal place to spread the good effects of laughter?",
                "options": ["sari-sari store", "gas station", "hospital", "market"],
                "correctAnswer": "hospital"
            }
        ]
    },
    {
        "title": "Sneezing",
        "content": "Sneezing happens when our body is trying to remove an\nirritation found inside the nose. A special name for this process\nis sternutation.\nHow does a sneeze happen? When your nose is tickled,\nthe sneeze center in our brain receives a message. Soon, the\nother parts of the body that work together to create a sneeze\nsuch as the abdominal muscles, chest muscles, the diaphragm,\nthe muscles of the vocal chords, the back of the throat, and\nthe eyelids receive this message. An explosion as fast as 161\nkilometers per hour sends the irritant speeding out of your nose.\nExamples of irritants in the air are dust, pepper, or allergens such\nas pollen. Some experience having a photic reflex and sneeze\nas soon as they are under the bright sun. Now, if it ever happens\nthat a sneeze of yours gets stuck, look towards a bright light to\nunstick your stuck sneeze.",
        "type": "pretest",
        "gradeLevel": "Grade 7",
        "set": "Set B",
        "quizzes": [
            {
                "question": "What is sternutation?",
                "options": ["the voluntary process of expelling dirt and dust from inside our nose", "the involuntary process of removing an irritation inside the nose", "a person’s natural reaction to bright light", "an explosion of allergens"],
                "correctAnswer": "the involuntary process of removing an irritation inside the nose"
            },
            {
                "question": "Sneezing happens ____________________________.",
                "options": ["to release energy", "to expel an irritant", "to remove nose hair", "in response to a cough"],
                "correctAnswer": "to expel an irritant"
            },
            {
                "question": "Which of the following is NOT an example of an allergic reaction?",
                "options": ["sneezing in a dusty room", "pepper-induced sternutation", "photic reflex from sun exposure", "sneezing when exposed to pollen"],
                "correctAnswer": "photic reflex from sun exposure"
            },
            {
                "question": "Which of the following does NOT help to create a sneeze?",
                "options": ["abdominal muscles", "chest muscles", "nasal passages", "voice box"],
                "correctAnswer": "voice box"
            },
            {
                "question": "Which is the best advice to follow to unstick a sneeze?",
                "options": ["look towards a bright light", "tickle our nostrils", "blow one’s nose", "cough out loud"],
                "correctAnswer": "look towards a bright light"
            },
            {
                "question": "Why must we cover our nose when we sneeze?",
                "options": ["to prevent the further intake of pepper powder", "to prevent the allergens from multiplying", "to prevent irritants from spreading", "to prevent ourselves from sneezing"],
                "correctAnswer": "to prevent irritants from spreading"
            },
            {
                "question": "Which of the following is the best thing to do if you feel a sneeze coming along?",
                "options": ["Take cold medicine.", "Have a body check-up.", "Move away from others.", "Open a window that faces a garden."],
                "correctAnswer": "Move away from others."
            },
            {
                "question": "The main idea of this selection is",
                "options": ["the different kinds of sneeze", "how sneezing happens", "the cure for sneezing", "the origin of sneezing"],
                "correctAnswer": "how sneezing happens"
            }
        ]
    },    
    {
        "title": "Al’s Bag",
        "content": "Al has a bag.\nIt has a mat.\nIt has buns.\nIt has bananas.\nBut it has ants too!\n“Ants! Ants!” says Al.\nAl lets the bag go.",
        "type": "pretest",
        "gradeLevel": "Grade 2",
        "set": "Set C",
        "quizzes": [
            {
                "question": "What is the name of the boy in the story?",
                "options": ["Al", "Alf", "Ants"],
                "correctAnswer": "Al"
            },
            {
                "question": "What does he have in his bag?",
                "options": ["a mat", "an apple", "an orange"],
                "correctAnswer": "a mat"
            },
            {
                "question": "What will he do?",
                "options": ["have a nap", "have a party", "have a snack"],
                "correctAnswer": "have a snack"
            },
            {
                "question": "Why does he let his bag go?",
                "options": ["He is afraid.", "He is glad.", "He is mad."],
                "correctAnswer": "He is afraid."
            },
            {
                "question": "Which sentence tells us why it is a good idea for the boy to let go of his bag?",
                "options": ["So the ants cannot get the food", "So the ants cannot bite him", "So the ants will be free"],
                "correctAnswer": "So the ants cannot bite him"
            }
        ]
    },
    {
        "title": "Ben’s Store",
        "content": "Ben has his own store.\n“Do you sell eggs?” asks Mel.\n“Yes, come in,” says Ben.\n“Do you sell milk?” asks Dante.\n“Yes, come in,” says Ben.\n“Do you sell hats?” asks Lala.\n“No, we do not sell hats,” says Ben.\n“But you can come in and have a look.”\nLala goes in. She gets a banana.",
        "type": "pretest",
        "gradeLevel": "Grade 3",
        "set": "Set C",
        "quizzes": [
            {
                "question": "Who is the main character in the story?",
                "options": ["Ben", "Lala", "Mel"],
                "correctAnswer": "Ben"
            },
            {
                "question": "What does he have?",
                "options": ["a school", "a store", "a hat"],
                "correctAnswer": "a store"
            },
            {
                "question": "What is the store for?",
                "options": ["a place used for fixing things", "a place used for selling things", "a place used for keeping things"],
                "correctAnswer": "a place used for selling things"
            },
            {
                "question": "What do you think does it sell?",
                "options": ["Ben’s store sells hats.", "Ben’s store sells toys.", "Ben’s store sells food."],
                "correctAnswer": "Ben’s store sells food."
            },
            {
                "question": "Why was it important for Lala to go in and 'have a look?'",
                "options": ["to find out what she can sell", "to find out what she can buy", "to find out what she can keep"],
                "correctAnswer": "to find out what she can buy"
            },
            {
                "question": "Which of these words best describes Ben?",
                "options": ["helpful", "greedy", "giving"],
                "correctAnswer": "helpful"
            }
        ]
    },    
    {
        "title": "Anansi’s Web",
        "content": "Anansi was tired of her web. So one day, she said “I will go live with the ant.”\nNow, the ant lived in a small hill. Once in the hill Anansi cried, “This place is too dark! I will go live with the bees.”\nWhen she got to the beehive, Anansi cried, “This place is too hot and sticky! I will go live with the beetle.”\nBut on her way to beetle’s home she saw her web. “Maybe a web is the best place after all.",
        "type": "pretest",
        "gradeLevel": "Grade 4",
        "set": "Set C",
        "quizzes": [
            {
                "question": "Where does Anansi live?",
                "options": ["in a beehive", "in a web", "in a hill"],
                "correctAnswer": "in a web"
            },
            {
                "question": "What was her problem?",
                "options": ["She was tired of living in other insects’ homes.", "She was tired of living in a web.", "She was tired of being a spider."],
                "correctAnswer": "She was tired of living in a web."
            },
            {
                "question": "Which of the following happened last?",
                "options": ["She went to beetle’s house.", "She went back to the web.", "She went to the beehive."],
                "correctAnswer": "She went back to the web."
            },
            {
                "question": "What would she have said at beetle’s home?",
                "options": ["“This place is not for me.”", "“This place can be better.”", "“This place is exactly like my web.”"],
                "correctAnswer": "“This place is not for me.”"
            },
            {
                "question": "Which of the following solved her problem?",
                "options": ["She tried out other insects’ homes.", "She stayed at home all day.", "She made a new home."],
                "correctAnswer": "She tried out other insects’ homes."
            },
            {
                "question": "At the end of the story, which statement do you think is she going to say?",
                "options": ["“My home is your home.”", "“Homes should be shared.”", "“There’s no place like home.”"],
                "correctAnswer": "“There’s no place like home.”"
            }
        ]
    },
    {
        "title": "Pedrito’s Snack",
        "content": "The bell rang. “It’s snack time!” Pedrito shouted and ran out of\nthe room. He sat on a bench under a tall tree.\nIn Pedrito’s lunch bag were three soft buns. He got the first\none and took a bite. “Mmmm,” said Pedrito. Just then, a sparrow\nsat on the bench. It was looking at him. Pedrito didn’t mind. He\nwent on and finished his bun.\nThen Pedrito got his second bun. He took a big bite and\nsaid “Mmmm!” The sparrow was still looking at him. It also moved\ncloser. But still, Pedrito did not mind. He went on and finished his\nbun.\nFinally, Pedrito got his last bun. He was about to take a bite\nwhen the sparrow flew up to his shoulder. Pedrito smiled, cut the\nbun in two and said to himself, “I think someone also likes bread\nand butter.”",
        "type": "pretest",
        "gradeLevel": "Grade 5",
        "set": "Set C",
        "quizzes": [
            {
                "question": "What was Pedrito excited about?",
                "options": ["having his favorite snack", "going to the bench", "being with the birds", "finding a friend"],
                "correctAnswer": "having his favorite snack"
            },
            {
                "question": "Which of the statements explains the sentence, “Pedrito didn’t mind.”",
                "options": ["Pedrito was not thinking.", "Pedrito was not bothered.", "Pedrito did not want to think.", "Pedrito did not want to be bothered."],
                "correctAnswer": "Pedrito was not bothered."
            },
            {
                "question": "Which of these was NOT mentioned in the story?",
                "options": ["The sparrow looked at the bread.", "The sparrow sat down on the bench.", "The sparrow moved closer to Pedrito.", "The sparrow flew onto Pedrito’s shoulder."],
                "correctAnswer": "The sparrow looked at the bread."
            },
            {
                "question": "What does the word ‘finished’ mean in the phrase \"finished his bun?\"",
                "options": ["The bun was eaten.", "The bun was prepared.", "The bun was thrown away.", "The bun was already spoiled."],
                "correctAnswer": "The bun was eaten."
            },
            {
                "question": "Why was the sparrow looking at him?",
                "options": ["It wanted to be a pet.", "It wanted to watch Pedrito as he ate.", "It wanted to have a share of the bun.", "It wanted to listen more closely to Pedrito."],
                "correctAnswer": "It wanted to have a share of the bun."
            },
            {
                "question": "Why did Pedrito have to break the third bun in two?",
                "options": ["So that he can eat the bun in two bites.", "So that he can cut up the bun some more.", "So that he can share it with the sparrow.", "So that he can save the other half for later."],
                "correctAnswer": "So that he can share it with the sparrow."
            },
            {
                "question": "Which of the following sentences best shows what Pedrito thought of at the end of the story?",
                "options": ["“Sharing is only true among friends.”", "“Ask and you shall receive.”", "“One good turn deserves another.”", "“Something good is even better when shared.”"],
                "correctAnswer": "“Something good is even better when shared.”"
            }
        ]
    },
    {
        "title": "Effects of Anger",
        "content": "Anger is often viewed as harmful. It does not only affect the\nperson feeling this anger but those around him or her. As these\nfeelings get stronger, changes occur in our body. Our faces turn\nred and carry a frown. Our teeth are clenched and our hands are\nclosed tight. Our breathing becomes heavy and this makes our\nheart beat faster. Our shoulder and neck muscles become stiff\nand our blood pressure begins to rise. All these things happen\nbecause our body is preparing for something. It is preparing for\naction. However, this action does not have to be harmful.\nPeople are often guilty about feeling angry. But, anger can\nbe viewed positively. Feelings of anger tell you that something is\nnot right and that something needs to change. The challenge lies\nin making sure that actions resulting from anger will help rather\nthan harm. Expressing our feelings can help others understand\nthe source of our anger rather than fear its consequences.",
        "type": "pretest",
        "gradeLevel": "Grade 6",
        "set": "Set C",
        "quizzes": [
            {
                "question": "Which is NOT an observed change in our body when we get angry?",
                "options": ["Our face turns red.", "Our heart beats faster.", "Our shoulders become stiff.", "Our breathing becomes slow."],
                "correctAnswer": "Our breathing becomes slow."
            },
            {
                "question": "In the sentence, “Changes occur in our body,” which of the following words is a synonym for the word occur?",
                "options": ["stay", "form", "happen", "transform"],
                "correctAnswer": "happen"
            },
            {
                "question": "Why do people sometimes feel guilty for being angry?",
                "options": ["Anger may hurt others.", "Anger is not a feeling you should show to other people.", "Anger may cause us to create positive change in the world.", "Anger may cause us to be motivated to act on something."],
                "correctAnswer": "Anger may hurt others."
            },
            {
                "question": "Which of these actions is based on anger as a positive form of expression?",
                "options": ["focusing on what is wrong", "saying hurtful words", "identifying the root of the problem", "keeping our emotions bottled up inside of us"],
                "correctAnswer": "identifying the root of the problem"
            },
            {
                "question": "Which of these actions are based on anger as a form of motivation?",
                "options": ["asking the person we are angry at to think of how the problem can be resolved", "giving the person that we are angry at the silent treatment", "kicking a chair aside and screaming out loud", "seeking the help of a third person to side with you"],
                "correctAnswer": "asking the person we are angry at to think of how the problem can be resolved"
            },
            {
                "question": "What is one benefit of feeling angry?",
                "options": ["It provides a form of exercise for our heart and blood vessels.", "It prepares us for future occasions that we might feel angry.", "It serves as a signal that something is not right.", "It changes how our mind works."],
                "correctAnswer": "It serves as a signal that something is not right."
            },
            {
                "question": "In the selection, what is the meaning of the word \"challenge?\"",
                "options": ["It refers to a task that is new.", "It refers to a task that is different.", "It refers to a task that is assigned to us.", "It refers to a task that is difficult to do."],
                "correctAnswer": "It refers to a task that is difficult to do."
            },
            {
                "question": "In the selection, which trait would be most helpful when trying to use our anger in a positive way?",
                "options": ["being obedient", "being honest", "being thoughtful", "being hardworking"],
                "correctAnswer": "being honest"
            }
        ]
    },
    {
        "title": "Dust",
        "content": "No matter how often we sweep the floor of our homes, we\nare still able to gather together a considerable amount of dust.\nDust is all around us. It gathers on bookshelves, on furniture -\nold or new. These particles rest on any still object – undisturbed\nuntil touched or wiped clean.\nDust, which was first believed to be made of dead skin has\nbeen found to be a mix of different things. Some of the common\ningredients of dust particles include animal fur, dead insects,\nfood, fiber from clothes, beddings, soil and other chemicals.\nAlthough most of household dust comes from the outside\nthrough doors, windows and shoes, other dust particles come\nfrom within. Scientists have discovered that the mix of dust from\neach household actually depends on four things: the climate, the\nage of the house, the number of persons who live in it and their\nindividual cooking, cleaning and smoking habits.\nMaking our homes free of dust may not be possible but\nlessening the amount of dust that we keep in our homes will help\navoid possible allergies and allow us to breathe well.",
        "type": "pretest",
        "gradeLevel": "Grade 7",
        "set": "Set C",
        "quizzes": [
            {
                "question": "Which of the following is NOT true about dust?",
                "options": ["Dust causes allergies.", "Dust is made of dead skin only.", "Dust comes from both within the home and outside of it.", "The amount of dust in the house may depend on the climate."],
                "correctAnswer": "Dust is made of dead skin only."
            },
            {
                "question": "Knowing the contents of the dust in our homes will determine ________.",
                "options": ["how dust can be cleaned up", "where the dust is coming from", "what one might add to one’s home", "the lifestyle of the occupants"],
                "correctAnswer": "the lifestyle of the occupants"
            },
            {
                "question": "Among the sources of dust, which is NOT within one’s control?",
                "options": ["the personal habits of family members", "the number of persons in the home", "the age of the house", "the climate"],
                "correctAnswer": "the climate"
            },
            {
                "question": "What is the greatest risk that one faces in having a dusty house? A dusty house might ________.",
                "options": ["cause the incidence of allergies", "be a reason for accidents in the house", "increase the temperature of the environment", "result in the early destruction of the furniture"],
                "correctAnswer": "cause the incidence of allergies"
            },
            {
                "question": "Knowing the composition of dust will especially help persons with ______.",
                "options": ["motor difficulties", "physical disabilities", "circulatory concerns", "respiratory problems"],
                "correctAnswer": "respiratory problems"
            },
            {
                "question": "In this selection, the word “habits” refers to ________.",
                "options": ["one’s unusual behavior", "being addicted to something", "the work one occasionally performs", "the manner by which one repeatedly does a task"],
                "correctAnswer": "the manner by which one repeatedly does a task"
            },
            {
                "question": "How did the writer develop this selection about dust?",
                "options": ["by giving examples", "by narrating some events", "by stating the cause and effect", "by identifying the problem and the solutions"],
                "correctAnswer": "by giving examples"
            },
            {
                "question": "Which is an appropriate title of this selection?",
                "options": ["Keeping the Houses Dust-Free", "Sources of Dust in Our Homes", "Effects of Dusty Homes", "Diseases Due to Dust"],
                "correctAnswer": "Sources of Dust in Our Homes"
            }
        ]
    },
    {
        "title": "Nat Takes a Nap",
        "content": "Nat will nap.\nHe will nap on his bed.\nBut Nat wet the bed.\nHe cannot nap.\nNat is sad.\nMama gets Nat.\nNat has his nap.",
        "type": "pretest",
        "gradeLevel": "Grade 2",
        "set": "Set D",
        "quizzes": [
            {
                "question": "Who will nap?",
                "options": ["Matt", "Nat", "Pat"],
                "correctAnswer": "Nat"
            },
            {
                "question": "Where did he want to nap?",
                "options": ["in the bed", "up the bed", "on the bed"],
                "correctAnswer": "on the bed"
            },
            {
                "question": "Why was he not able to take a nap?",
                "options": ["Mama was not there.", "It was not time to nap.", "He did not want to get wet."],
                "correctAnswer": "He did not want to get wet."
            },
            {
                "question": "Who helped him have his nap?",
                "options": ["Mama", "Papa", "No one"],
                "correctAnswer": "Mama"
            },
            {
                "question": "What did he feel when Mama got him?",
                "options": ["glad", "sad", "afraid"],
                "correctAnswer": "glad"
            }
        ]
    },
    {
        "title": "Waiting for Her Sister",
        "content": "Mara sat by the school gate.\nIt was the end of the day.\nMara looked at her watch.\n“Where is Ate Mila?” she asked.\nMara looked at her watch again.\nAt last, Mila has come to pick her up.\n“Let’s go home. Mama said it’s time for dinner,” says Mila.\n“I am glad you are here,” says Mara.",
        "type": "pretest",
        "gradeLevel": "Grade 3",
        "set": "Set D",
        "quizzes": [
            {
                "question": "What did Mara want to do?",
                "options": ["go home", "go to school", "go on a long trip"],
                "correctAnswer": "go home"
            },
            {
                "question": "Why was Mara by the school gate?",
                "options": ["She could not carry her big school bag.", "She was waiting for her sister.", "She wanted to know the time."],
                "correctAnswer": "She was waiting for her sister."
            },
            {
                "question": "What part of the day was it?",
                "options": ["the start of the school day", "the middle of the school day", "the end of the school day"],
                "correctAnswer": "the end of the school day"
            },
            {
                "question": "What does the phrase 'pick up' mean?",
                "options": ["to get from the floor", "to fetch someone and bring them home", "to deliver something from one place to another"],
                "correctAnswer": "to fetch someone and bring them home"
            },
            {
                "question": "Why did Mara keep looking at her watch?",
                "options": ["She wanted to check for the time.", "She was worried that it was getting late.", "She wanted to know the time that Mila left."],
                "correctAnswer": "She was worried that it was getting late."
            },
            {
                "question": "Which of these is the best thing for Mila to do so that Mara will not be so worried? Mila should ________________.",
                "options": ["come on time", "give her a big hug", "bring a friend along"],
                "correctAnswer": "come on time"
            }
        ]
    },
    {
        "title": "Wake Up!",
        "content": "Every Saturday, Manuel goes to market with his father, Mang Ador. They always pass by Aling Juaning’s stall to buy meat. They go to Mang Tinoy’s for fresh vegetables. They also visit Aling Tita’s seafood section. Whenever Mang Ador buys something, Manuel always tries to predict what his father will cook for lunch. Today, Mang Ador bought tamarind, tomatoes, string beans, radish, and shrimp. “I know what we will have for lunch,” says Manuel happily. Can you guess it, too?",
        "type": "pretest",
        "gradeLevel": "Grade 4",
        "set": "Set D",
        "quizzes": [
            {
                "question": "What woke Toto’s family up?",
                "options": ["a fire truck", "a loud knock", "shouts from the neighbors"],
                "correctAnswer": "a loud knock"
            },
            {
                "question": "Which of these details tells us that this story happened in the evening?",
                "options": ["Toto’s family was home.", "Toto’s family was asleep.", "Toto’s family had to dress up."],
                "correctAnswer": "Toto’s family was asleep."
            },
            {
                "question": "Which answer best explains why his family was in a hurry?",
                "options": ["The fire fighters were almost there.", "The fire was very near.", "It was getting late."],
                "correctAnswer": "The fire was very near."
            },
            {
                "question": "Who helped them flee from the fire?",
                "options": ["the firefighters", "the neighbors", "their relative"],
                "correctAnswer": "their relative"
            },
            {
                "question": "Which of these words best describes the family?",
                "options": ["alert", "helpful", "trustworthy"],
                "correctAnswer": "alert"
            },
            {
                "question": "Which advice in the story tells us how to avoid getting burned?",
                "options": ["call for help", "dress up quickly", "wrap yourself in a wet towel"],
                "correctAnswer": "wrap yourself in a wet towel"
            }
        ]
    },
    {
        "title": "Amy's Good Deed",
        "content": "Amy loves walking home from school to see the colors of the leaves and listen to the birds sing. But one day, she heard a soft cry. It came from under a bush. “Should I go near?” Amy wondered. As it grew louder, Amy decided she must help the poor thing. Amy crept closer and held her arm out. Just when she was about to reach out, she saw a pair of eyes and heard a loud “Hissss!!!!” She also felt a sharp pain. “Ouch!” Amy cried. Her arm had four long scratch marks. Amy was upset. She really thought she was doing a good deed.",
        "type": "pretest",
        "gradeLevel": "Grade 5",
        "set": "Set D",
        "quizzes": [
            {
                "question": "What does Amy love to do?",
                "options": ["catching animals", "listening to the trees", "walking home from school", "seeing the colors of the birds"],
                "correctAnswer": "walking home from school"
            },
            {
                "question": "What did she find unusual?",
                "options": ["the thorny bush", "the cry of an animal", "the colors of the leaves", "the singing of the birds"],
                "correctAnswer": "the cry of an animal"
            },
            {
                "question": "What did Amy want to do?",
                "options": ["She wanted to save the animal.", "She wanted to scare the animal.", "She wanted to hurt the animal.", "She wanted to keep the animal."],
                "correctAnswer": "She wanted to save the animal."
            },
            {
                "question": "What happened when she tried to help?",
                "options": ["She was yelled at.", "She was scratched.", "She was bitten.", "She was pulled forward."],
                "correctAnswer": "She was scratched."
            },
            {
                "question": "Why did the animal react that way?",
                "options": ["The animal was getting ready to attack.", "The animal wanted to be friends.", "The animal was scared of Amy.", "The animal wanted to play."],
                "correctAnswer": "The animal was scared of Amy."
            },
            {
                "question": "What for Amy is a 'good deed?'",
                "options": ["a surprise", "a harmful act", "a brave action", "an act of kindness"],
                "correctAnswer": "an act of kindness"
            },
            {
                "question": "Which phrase best describes Amy?",
                "options": ["a hardworking girl", "a brave pet owner", "a caring person", "a diligent student"],
                "correctAnswer": "a caring person"
            }
        ]
    },
    {
        "title": "Dreams",
        "content": "We often say “Sweet dreams,” but have you ever wondered why we dream? Some say that dreaming is our brain’s way of exercising. While we sleep, our brain may be testing the connections and pathways to see if they are working well. Others believe that dreaming is our brain’s way of sorting out problems. Problems that have not been addressed during the day are sometimes resolved in our sleep. Yet another explanation is that dreaming is our brain’s way of fixing and organizing all the information we have. While sleeping, our brains have a chance to sort out the information that we want to keep from the stuff we no longer want. Still another idea is that dreams are just another form of thinking. Will we ever get to know the answer to this question? Maybe we should sleep on it.",
        "type": "pretest",
        "gradeLevel": "Grade 6",
        "set": "Set D",
        "quizzes": [
            {
                "question": "Based on the selection, what does our brain exercise through sleeping?",
                "options": ["the connections and pathways", "the left and right hemispheres", "the content and concepts", "the gray matter"],
                "correctAnswer": "the connections and pathways"
            },
            {
                "question": "Which of the statements does NOT show how dreams fix our problems?",
                "options": [
                    "As we dream, we constantly think about what we have learned or experienced.",
                    "Our dreams help us focus on things we are unable to notice during the day.",
                    "Our brain comes up with solutions in our sleep.",
                    "Our brain sorts and files information."
                ],
                "correctAnswer": "Our brain sorts and files information."
            },
            {
                "question": "How does a brain - through dreams - perform the function of an office clerk?",
                "options": [
                    "It sorts information we need from what we don’t need.",
                    "It files what we know into fixed categories.",
                    "It clears the board to store new information.",
                    "It functions alone."
                ],
                "correctAnswer": "It sorts information we need from what we don’t need."
            },
            {
                "question": "Based on how it is used in the selection, which of the following words is a synonym for the word 'resolved?'",
                "options": ["accommodated", "reflected", "decided", "fixed"],
                "correctAnswer": "fixed"
            },
            {
                "question": "Which of the following statements is NOT true about the brain?",
                "options": [
                    "Our brain makes connections.",
                    "Our brain never stops thinking.",
                    "Sleeping is our brain’s way of shutting down.",
                    "Our brain replays our experiences as we sleep."
                ],
                "correctAnswer": "Sleeping is our brain’s way of shutting down."
            },
            {
                "question": "Which question is the selection trying to answer?",
                "options": [
                    "What are the types of dreams?",
                    "Why are our reasons for dreaming?",
                    "Are all dreams sweet?",
                    "How can we stop from dreaming?"
                ],
                "correctAnswer": "Why are our reasons for dreaming?"
            },
            {
                "question": "In the selection, what does it mean to 'sleep on it?'",
                "options": ["ignore it", "take a nap", "think about it", "forget about it"],
                "correctAnswer": "think about it"
            },
            {
                "question": "Which could be a good title for this selection?",
                "options": [
                    "Dreaming: Explained",
                    "Preventing Our Dreams",
                    "Interpreting One’s Dream",
                    "Finding Solutions to Dreaming"
                ],
                "correctAnswer": "Dreaming: Explained"
            }
        ]
    },
    {
        "title": "Pain",
        "content": "How do we sense pain? The human body has nociceptors to receive an electrical impulse that is sent to part of the brain that recognizes pain. Memories of these sensations are formed to help us avoid painful objects and experiences and prevents us from repeating past mistakes that may have hurt us in some way. But pain is more complex. It is not only a physical experience but an emotional and psychological one as well. When all of these come together, it is called suffering. The mind is not alone in recognizing pain. The nervous system is also able to store such information. Even when a person loses a finger or a limb, the pain that was once felt may become a chronic one – one that keeps recurring. The best way to avoid this is to prevent pain memories from forming. The use of anesthesia prevents the mind from creating these memories. Drugs that prevent pain such as analgesics help lessen the pain sensed.",
        "type": "pretest",
        "gradeLevel": "Grade 7",
        "set": "Set D",
        "quizzes": [
            {
                "question": "What are \"nociceptors?\"",
                "options": ["electrical impulses", "memories of pain", "nerve receptors", "sensations of pain"],
                "correctAnswer": "nerve receptors"
            },
            {
                "question": "How do memories of pain help us?",
                "options": [
                    "These constantly remind us of what hurts.",
                    "These help dull the senses.",
                    "These help us re-experience the pain.",
                    "These inform us on what to watch out for."
                ],
                "correctAnswer": "These inform us on what to watch out for."
            },
            {
                "question": "Suffering is the complex mix of __________________.",
                "options": [
                    "physical, mental and spiritual experiences",
                    "physical, psychological and social influences",
                    "physical, sociological and cognitive factors",
                    "physical, emotional and psychological experiences"
                ],
                "correctAnswer": "physical, emotional and psychological experiences"
            },
            {
                "question": "Which of the following is an example of how memories of pain help us?",
                "options": [
                    "A baby crying at the sight of the needle",
                    "Drinking a pain killer once a headache starts",
                    "Asking if a dental procedure will hurt",
                    "We relive these experiences through our dreams"
                ],
                "correctAnswer": "Drinking a pain killer once a headache starts"
            },
            {
                "question": "Which is an example of helping the body avoid the creation of memories for pain?",
                "options": [
                    "Avoiding the use of anesthesia",
                    "Drinking a painkiller once a headache starts",
                    "Talking about a painful experience with a friend",
                    "Being given an anesthetic before a dental procedure"
                ],
                "correctAnswer": "Being given an anesthetic before a dental procedure"
            },
            {
                "question": "In the selection, how was the word 'chronic' used in the phrase “chronic pain?”",
                "options": ["continuous", "in-born", "throbbing", "worsening"],
                "correctAnswer": "continuous"
            },
            {
                "question": "Which of the following adjectives best describes our memories’ role in managing pain?",
                "options": ["curative", "corrective", "preventive", "restorative"],
                "correctAnswer": "preventive"
            },
            {
                "question": "In the selection, what does it mean to ‘sense pain’?",
                "options": ["create pain", "recognize pain", "remember pain", "understand pain"],
                "correctAnswer": "recognize pain"
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
        throw new Error(`Correct answer ${quiz.correctAnswer} not found in options for question: ${quiz.question}`);
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
