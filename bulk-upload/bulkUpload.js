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
      title: "Pam's Cat",
      content: `
        
        Pam has a cat.
        It is on the bed.
        It can nap. It can sit.
        "Oh no!" says Pam.
        "The cat fell off the bed!"
        Is the cat sad?
        No. It is on the mat
        `,
      type: "pretest",
      gradeLevel: "2",
      set: "A",
      quizzes: [
        {
          question: "Who has a pet?",
          options: ["Pat", "Pam", "Paz"],
          correctAnswer: "Pam"
        },
        {
          question: "What is her pet?",
          options: ["Dog", "Pig", "Cat"],
          correctAnswer: "Cat"
        },
        {
          question: "Why did Pam say 'Oh no!'?",
          options: ["She was mad", "She was Happy", "She was worried"],
          correctAnswer: "She was worried"
        },
        {
          question: "Why did she feel this way?",
          options: ["Her cat can't do tricks", "Her cat made a mess", "Her cat might be hurt"],
          correctAnswer: "Her cat might be hurt"
        },
        {
          question: "How do we know that the cat is ok?",
          options: ["It is on bed", "It is on mat", "It has a rat"],
          correctAnswer: "It is on mat"
        }
      ]
    },
    {
      title: "Summer Fun",
      content: `
      
        Let’s have some fun this summer,” says Leo.
        “Let’s swim in the river,” says Lina.
        “Let’s get some star apples from the tree,” says Leo.
        “Let’s pick flowers,” says Lina.
        “That is so much fun!” says Mama.
        “But can you help me dust the shelves too?”
        “Yes, we can Mama,” they say.
        “Helping can be fun too!” 
        `,
      type: "pretest",
      gradeLevel: "3",
      set: "A",
      quizzes: [
        {
          question: "Who were talking to each other?",
          options: ["Lita and Lito", "Lina and Lino", "Lina and Leo"],
          correctAnswer: "Lina and Leo"
        },
        {
          question: "What were they talking about?",
          options: ["what to do during the summer", "what to have during the summer", "what to wear during the summer"],
          correctAnswer: "what to do during the summer"
        },
        {
          question: "The children in the story could be _______",
          options: ["brother and sister", "neighbors", "cousins"],
          correctAnswer: "brother and sister"
        },
        {
          question: "Which of these will they do if they are hungry?",
          options: ["pick flowers", "pick guavas", "go swimming"],
          correctAnswer: "pick guavas"
        },
        {
          question: "Doing something 'fun' means ______________.",
          options: ["doing something in the summer", "doing something in the house", "doing something that we like"],
          correctAnswer: "doing something that we like"
        },
        {
          question: "Which of these is the best example of being helpful?",
          options: ["picking flowers.", "cleaning up", "swimming"],
          correctAnswer: "cleaning up"
        }
      ]
    },
    {
      title: "Get up, Jacky!",
      content: `
      
        “Ring! Ring!” rang the clock.
        But Jacky did not get up.
      “Wake up, Jacky! Time for school,” yelled Mom.
        And yet Jacky did not get up.
      “Beep! Beep!” honked the horn of the bus.
        Jacky still laid snug on the bed.
        Suddenly, a rooster crowed out loud
        and sat on the window sill.
        Jacky got up and said with cheer,
      “I will get up now. I will!”
 
        `,
      type: "pretest",
      gradeLevel: "4",
      set: "A",
      quizzes: [
        {
          question: "Who is the main character in our story?",
          options: ["Jock", "Jicky", "Jacky"],
          correctAnswer: "Jacky"
        },
        {
          question: "Why did the main character need to wake up early?",
          options: ["to get to school on time", "to get to work on time", "to get to bed on time"],
          correctAnswer: "to get to school on time"
        },
        {
          question: "What woke the character up? ",
          options: ["the ringing of the alarm clock", "the crowing of the rooster", "Mom’s yelling"],
          correctAnswer: "the crowing of the rooster"
        },
        {
          question: "What did the character think as he/she \"laid snug\" on the bed? ",
          options: ["\“I do not want to get up yet.\”", "\“I do not want to be late today.\”", "“\I want to be extra early today.\”"],
          correctAnswer: "\“I do not want to get up yet.\”"
        },
        {
          question: "What does it mean to say something \"with cheer?\"",
          options: ["We say it sadly.", "We say it happily", "We say it with fear."],
          correctAnswer: "We say it happily"
        },
        {
          question: "Which of these statements fits the story?",
          options: ["Jacky liked being woken up by a clock", "Jacky liked being woken up by a bus horn", "Jacky liked being woken up by a rooster"],
          correctAnswer: "Jacky liked being woken up by a rooster"
        }
      ]
    },
    {
      title: "Frog's Lunch",
      content: `
      
        One day, a frog sat on a lily pad, still as a rock.
A fish swam by.
“Hello, Mr. Frog! What are you waiting for?”
“I am waiting for my lunch,” said the frog.
“Oh, good luck!” said the fish and swam away.
Then, a duck waddled by.
“Hello, Mr. Frog! What are you waiting for?”
“I am waiting for my lunch,” said the frog.
“Oh, good luck!” said the duck and waddled away.
Then a bug came buzzing by.
“Hello, Mr. Frog! What are you doing?” asked the bug.
“I’m having my lunch! Slurp!” said the frog.
Mr. Frog smiled. 
 
        `,
      type: "pretest",
      gradeLevel: "5",
      set: "A",
      quizzes: [
        {
          question: "Who is the main character in the story? ",
          options: ["the bug", "the duck", "the fish", "the frog"],
          correctAnswer: "the frog"
        },
        {
          question: "What was he doing?",
          options: ["resting on a lily pad", "chatting with a bug", "hunting for his food", "waiting for the rain"],
          correctAnswer: "hunting for his food"
        },
        {
          question: "In what way was he able to get his lunch?",
          options: ["He was able to fool the fish", "He was able to fool the duck", "He was able to fool the rock", "He was able to fool the bug"],
          correctAnswer: "He was able to fool the bug"
        },
        {
          question: "Why should the frog be \“still as a rock?\”",
          options: ["so that he will not scare the other animals away", "so that he can catch his lunch", "so that the other animals will think he is friendly", "so that the fish will say nice things about him"],
          correctAnswer: "so that he can catch his lunch"
        },
        {
          question: "Which of these words describe the duck?",
          options: ["patient", "eager", "curious", "careful"],
          correctAnswer: "curious"
        },
        {
          question: "Which of these words describe Mr. Frog?",
          options: ["patient", "eager", "curious", "careful"],
          correctAnswer: "patient"
        },
        {
          question: "Which of these characteristics would have helped the bug? ",
          options: ["being patient", "being eager", "being curious", "being careful"],
          correctAnswer: "being careful"
        }
      ]
    },
    {
      title: "Yawning",
      content: `
      
        What makes us yawn? Yawning is something that we
cannot control. Even in the mother’s womb, eleven-week-old
babies have been observed to yawn. But why do we do it?
One popular explanation for yawning is that a person may be
tired or bored. Although many believe this to be true, it cannot
explain why athletes yawn before an event or why dogs yawn
before an attack.
It is said that yawning is caused by a lack of oxygen and
excess carbon dioxide. A good example of this is when we yawn
in groups. We yawn because we are competing for air.
Others even believe that we yawn to cool our brains off.
Cool brains allow us to think more clearly so yawning is said to
help us become more alert
 
        `,
      type: "pretest",
      gradeLevel: "6",
      set: "A",
      quizzes: [
        {
          question: "What is a fact about yawning?",
          options: ["It is something we cannot control", "It is something only humans do", "It is a result of boredom", "It happens after birth"],
          correctAnswer: "It is something we cannot control"
        },
        {
          question: "Which of the following might make us yawn?",
          options: ["reading a book", "being in a crowded room", "being around plants", "being in a small air-conditioned car"],
          correctAnswer: "being in a crowded room"
        },
        {
          question: "What does the word \"involuntary\" mean?",
          options: ["expected", "unexpected", "within control", "uncontrollable"],
          correctAnswer: "uncontrollable"
        },
        {
          question: "Which of the following may be a benefit of yawning?",
          options: ["It warns us of possible attacks by dogs", "It provides us the carbon dioxide we need", "It cools our brains", "It balances the amount of oxygen and carbon dioxide"],
          correctAnswer: "It cools our brains"
        },
        {
          question: "According to the selection, what is most likely to happen after we yawn?",
          options: ["We will become more alert", "We will be less tired", "We will be less sleepy", "We will be calmer"],
          correctAnswer: "We will become more alert"
        },
        {
          question: "In the selection, how is the word 'compete' used in the phrase\"competing for air?\"",
          options: ["struggling to take in some air", "arguing about breathing", "battling it out for oxygen", "racing to breathe more air"],
          correctAnswer: "struggling to take in some air"
        },
        {
          question: "Which of the following shows evidence that \"yawning\" is \"competing for air?\"",
          options: ["The passengers in an elevator yawned", "Several people yawned while picnicking at an open field", "Two people yawned inside a room with air-conditioning", "Three students yawned in a big empty room"],
          correctAnswer: "The passengers in an elevator yawned"
        },
        {
          question: "Which of the following is the best response when we see a person/animal yawn?",
          options: ["Have the person eat a food item that is a good source of energy", "Change the topic of conversation to a more interesting one", "Turn on an electric fan or source of ventilation", "Run away to avoid being attacked"],
          correctAnswer: "Turn on an electric fan or source of ventilation"
        }
      ]
    },
    {
      title: "Dark Chocolate",
      content: `
              Dark chocolate finds its way into the best ice creams,
biscuits and cakes. Although eating chocolate usually comes
with a warning that it is fattening, it is also believed by some
to have magical and medicinal effects. In fact, cacao trees are
sometimes called Theobroma cacao which means “food of the
gods.”
Dark chocolate has been found out to be helpful in small
quantities. One of its benefits is that it has some of the most
important minerals and vitamins that people need. It has
antioxidants that help protect the heart. Another important
benefit is that the fat content of chocolate does not raise the
level of cholesterol in the blood stream. A third benefit is that it
helps address respiratory problems. Also, it has been found out
to help ease coughs and respiratory concerns. Finally, chocolate
increases serotonin levels in the brain. This is what gives us a
feeling of well-being.
        `,
      type: "pretest",
      gradeLevel: "7",
      set: "A",
      quizzes: [
        {
          question: "Why was chocolate called Theobroma cacao? It is considered to be _____.",
          options: ["fattening food", "magical tree", "medicinal candy", "food of the gods"],
          correctAnswer: "food of the gods"
        },
        {
          question: "Which statement is true?",
          options: ["All chocolates have medicinal properties", "In small doses, dark chocolate is fattening", "Dark chocolate has minerals and vitamins", "Chocolate raises the level of cholesterol"],
          correctAnswer: "Dark chocolate has minerals and vitamins"
        },
        {
          question: "What is found in dark chocolate that will help encourage its consumption?",
          options: ["antioxidants", "sugar", "fats", "milk"],
          correctAnswer: "antioxidants"
        },
        {
          question: "After we eat chocolate, which of these is responsible for making us feel good?",
          options: ["cacao", "theobroma", "serotonin", "antioxidants"],
          correctAnswer: "serotonin"
        },
        {
          question: "If a person coughs and is asked to have some chocolate, why would this be good advice?",
          options: ["Dark chocolate helps respiratory problems", "Dark chocolate helps circulation", "Dark chocolate does not raise the level of cholesterol", "Dark chocolate has vitamins and minerals"],
          correctAnswer: "Dark chocolate helps respiratory problems"
        },
        {
          question: "Which of the following body systems does not directly benefit from the consumption of dark chocolate? ",
          options: ["Circulatory system", "Respiratory system", "Excretory system", "Nervous system"],
          correctAnswer: "Excretory system"
        },
        {
          question: "Which important fact shows that dark chocolate may be safe for the   heart?",
          options: ["It may ease coughs", "It helps address respiratory problems", "It does not raise the level of cholesterol", "In small quantities, dark chocolate has been said to be medicinal"],
          correctAnswer: "It does not raise the level of cholesterol"
        },
        {
          question: "What does “address” mean in the second paragraph?",
          options: ["to locate", "to identify", "to deal with", "to recognize"],
          correctAnswer: "to deal with"
        }
      ]
    },
    {
      title: "A Hot Day",
      content: `
              The sun is up.
        “Is it a hot day, Matt?” asks Sal.
          “Yes, it is,” says Matt.
          Sal gets her fan.
          Matt gets his hat.
              Sal and Matt go out to play.
            Sal and Matt have fun.
        `,
      type: "pretest",
      gradeLevel: "2",
      set: "B",
      quizzes: [
        {
          question: "Who are the children in the story?",
          options: ["Sam and Matt", "Sal and Max", "Matt and Sal"],
          correctAnswer: "Matt and Sal"
        },
        {
          question: "What kind of day was it?",
          options: ["a sunny day", "a cloudy day", "a rainy day"],
          correctAnswer: "a sunny day"
        },
        {
          question: "What did the little girl do so that she will not feel hot?",
          options: ["She stayed inside", "She got a hat", "She got a fan"],
          correctAnswer: "She got a fan"
        },
        {
          question: "What did the little boy do so that he will not feel hot? ",
          options: ["He stayed inside", "He got a hat", "He got a fan"],
          correctAnswer: "He got a hat"
        },
        {
          question: "What is the message of the story?",
          options: ["We can have fun on a hot day", "We can have fun on a cool day", "We can have fun on a cloudy day"],
          correctAnswer: "We can have fun on a hot day"
        }
      ]
    },
    {
      title: "A Rainy Day",
      content: `
              Nina and Ria are looking out the window.
“I do not like getting wet in the rain,” says Nina.
“What can we do?” asks Ria.
“We can play house,” says Nina.
“Or we can play tag,” says Ria.
“Okay, let’s play tag. You’re it!” says Nina.
Nina runs from Ria and bumps a lamp.
“Oh no!” says Nina.
“We must not play tag in the house.”

        `,
      type: "pretest",
      gradeLevel: "3",
      set: "B",
      quizzes: [
        {
          question: "What is it that Ria does not like? ",
          options: ["playing tag", "playing house", "getting wet in the rain"],
          correctAnswer: "getting wet in the rain"
        },
        {
          question: "What does Nina want to do?",
          options: ["play tag", "play house", "get wet in the rain"],
          correctAnswer: "play tag"
        },
        {
          question: "Who wants to play tag?",
          options: ["Ria", "Nina", "Ria and Nina"],
          correctAnswer: "Ria and Nina"
        },
        {
          question: "What is \"tag?\" ",
          options: ["a card game", "a video game", "a running game"],
          correctAnswer: "a running game"
        },
        {
          question: "Why wasn’t it a good idea to play tag in the house?",
          options: ["Something might break", "Someone might get tired", "Something might get lost"],
          correctAnswer: "Something might break"
        },
        {
          question: "Which word tells what Ria and Nina should be?",
          options: ["careless", "careful", "curious"],
          correctAnswer: "careful"
        }
      ]
    },
  ];

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