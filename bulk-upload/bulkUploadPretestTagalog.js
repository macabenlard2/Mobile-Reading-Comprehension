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
        "title": "Ang Daga",
        "content": "Pumunta sa lawa si Tito.\nKasama niya si Lina sa lawa.\nMalayo ang lawa.\nNakita nila ang palaka sa lawa.\nNakita nila ang bibe sa lawa.\nNakita rin nila ang buwaya.\nNaku! Ang laki ng buwaya!",
        "type": "pretest",
        "gradeLevel": "Grade 1",
        "set": "Set A",
        "quizzes": [
            {
                "question": "Ano ang nasa mesa?",
                "options": ["baso", "daga", "pusa"],
                "correctAnswer": "daga"
            },
            {
                "question": "Anong mayroon ang daga?",
                "options": ["damit", "laruan", "pagkain"],
                "correctAnswer": "pagkain"
            },
            {
                "question": "Ano ang unang nangyari sa kuwento?",
                "options": [
                    "Nakita ng pusa ang daga.",
                    "Nakita ng daga ang keso.",
                    "Tumakas ang daga sa pusa."
                ],
                "correctAnswer": "Nakita ng daga ang keso."
            },
            {
                "question": "Ano ang gagawin ng daga sa keso?",
                "options": ["lulutuin", "kakainin", "paglalaruan"],
                "correctAnswer": "kakainin"
            },
            {
                "question": "Bakit kaya nawala ang daga?",
                "options": ["natakot sa pusa", "nahuli ng bata", "ayaw maagawan ng keso"],
                "correctAnswer": "natakot sa pusa"
            }
        ]
    },
    {
        "title": "Si Mila",
        "content": "Si Mila ay nakatira sa bukid.\nMaraming hayop sa bukid.\nMarami ring halaman sa bukid.\nMaraming alagang hayop si Mila.\nMay alagang baboy si Mila.\nMay alaga din siyang baka at kambing.\nSa mga hayop niya, ang manok niya ang kanyang paborito.\nTiko ang pangalan ng manok niya.\nSi Tiko ay kulay pula at puti.\nSiya ang gumigising kay Mila tuwing umaga.\nMasaya si Mila kapag naririnig ang tilaok ni Tiko.",
        "type": "pretest",
        "gradeLevel": "Grade 2",
        "set": "Set A",
        "quizzes": [
            {
                "question": "Sino ang may alaga?",
                "options": ["si Mila", "si Olla", "si Tiko"],
                "correctAnswer": "si Mila"
            },
            {
                "question": "Saan nakatira si Mila?",
                "options": ["sa zoo", "sa Maynila", "sa probinsya"],
                "correctAnswer": "sa probinsya"
            },
            {
                "question": "Ano ang alaga ni Mila?",
                "options": ["isda", "buwaya", "tandang"],
                "correctAnswer": "tandang"
            },
            {
                "question": "Paano ginigising ni Tiko si Mila sa umaga?",
                "options": ["tumatahol", "tumitilaok", "umiiyak"],
                "correctAnswer": "tumitilaok"
            },
            {
                "question": "Ano ang isa pang magandang pamagat ng kuwento?",
                "options": ["Ang Tandang ni Mila", "Ang Kambing ni Mila", "Hayop sa Gubat"],
                "correctAnswer": "Ang Tandang ni Mila"
            }
        ]
    },
    {
        "title": "Magpalipad Tayo ng Saranggola",
        "content": "Maganda ang panahon. Gustong maglaro ni Niko. Niyaya ni Niko na maglaro ang kakambal na si Noli. Pumunta ang kambal sa labas. May dala silang mga saranggola. Makukulay ang mga saranggola ng kambal. Pinalipad agad nila ang mga saranggola. Mataas ang lipad ng saranggola ni Niko. Napansin ni Niko si Noli. Malungkot ang mukha ni Noli habang nakatingin kay Niko. “Halika, tuturuan kita kung paano paliparin ang saranggola.” sabi ni Niko. Tumingin si Noli. Ipinakita ni Niko kay Noli kung paano magpalipad. Ilang saglit pa, nakangiti na si Noli. “Salamat, Niko,” wika niya. “Maraming salamat mga bata. Natatapos agad ang gawain kung nagtutulungan,” sabi niya.",
        "type": "pretest",
        "gradeLevel": "Grade 3",
        "set": "Set A",
        "quizzes": [
            {
                "question": "Saan pumunta ang mga bata?",
                "options": ["sa labas", "sa paaralan", "sa simbahan"],
                "correctAnswer": "sa labas"
            },
            {
                "question": "Ano ang gusto nilang gawin?",
                "options": ["kumain", "maglaro", "magpahinga"],
                "correctAnswer": "maglaro"
            },
            {
                "question": "Anong panahon kaya magandang magpalipad ng saranggola?",
                "options": ["maaraw", "mahangin", "maulan"],
                "correctAnswer": "mahangin"
            },
            {
                "question": "Bakit kaya tinuruan ni Niko ng tamang paglipad si Noli?",
                "options": ["Walang sariling saranggola si Niko.", "Nasira ang hawak na saranggola ni Niko.", "Hindi mapalipad ni Niko ang saranggola niya."],
                "correctAnswer": "Hindi mapalipad ni Niko ang saranggola niya."
            },
            {
                "question": "Anong uri ng kapatid si Niko?",
                "options": ["maasikaso", "magalang", "matulungin"],
                "correctAnswer": "matulungin"
            },
            {
                "question": "Bakit napangiti na si Noli sa katapusan ng kuwento?",
                "options": ["Napalipad na niya ang saranggola.", "Binigyan siya ng premyo.", "Nanalo siya sa paglalaro."],
                "correctAnswer": "Napalipad na niya ang saranggola."
            }
        ]
    },
    {
        "title": "Isang Pangarap",
        "content": "Kasama si Jamil, isang batang Muslim, sa sumalubong sa pagdating ng kanyang tiyuhin.\n“Tito Abdul, saan po ba kayo galing?” tanong ni Jamil.\n“Galing ako sa Mecca, ang banal na sambahan nating mga Muslim.\nBawat isa sa atin ay nangangarap na makapunta roon. Mapalad ako dahil\nnarating ko iyon.”\n“Bakit ngayon po kayo nagpunta roon?”\n“Kasi, isinasagawa natin ngayon ang Ramadan, ang pinakabanal na\ngawain ng mga Muslim. Pag-alala ito sa ating banal na aklat na tinatawag na\nKoran. Doon ipinahayag na sugo ni Allah si Mohammed.”\n“Alam ko po ang Ramadan. Nag-aayuno tayo at hindi kumakain mula\nsa pagsikat ng araw hanggang hapon.”\n“Oo. Isang paraan kasi natin ito upang ipakita ang pagsisisi sa nagawa\nnating kasalanan.”\n“Pangarap ko rin pong makapunta sa Mecca,” sabi ni Jamil.",
        "type": "pretest",
        "gradeLevel": "Grade 4",
        "set": "Set A",
        "quizzes": [
            {
                "question": "Saang banal na sambahan nanggaling si Tito Abdul?",
                "options": ["sa Mecca", "sa Israel", "sa Jerusalem", "sa Bethlehem"],
                "correctAnswer": "sa Mecca"
            },
            {
                "question": "Ano ang tawag sa banal na aklat ng mga Muslim?",
                "options": ["Bibliya", "Koran", "Misal", "Vedas"],
                "correctAnswer": "Koran"
            },
            {
                "question": "Ano ang pakiramdam ni Tito Abdul nang makarating siya sa Mecca?",
                "options": ["nagsisi", "napagod", "nasiyahan", "nanghinayang"],
                "correctAnswer": "nasiyahan"
            },
            {
                "question": "Ano ang natupad sa pagpunta ni Tito Abdul sa Mecca?",
                "options": ["ang pangako kay Allah", "ang plano na makapangibang-bansa", "ang tungkulin na makapagsisi sa mga kasalanan", "ang pangarap na makapunta sa banal na sambahan"],
                "correctAnswer": "ang pangarap na makapunta sa banal na sambahan"
            },
            {
                "question": "Anong katangian ang pinapakita nina Tito Abdul at Jamil?",
                "options": ["magalang", "masunurin", "maalalahanin", "mapagbigay"],
                "correctAnswer": "masunurin"
            },
            {
                "question": "Ano ang tingin ni Jamil sa kanyang Tito Abdul?",
                "options": ["Mahusay siyang maglakbay.", "Siya ay isang mapagmahal na ama.", "Isa siyang masipag na mamamayan.", "Siya ay isang magandang halimbawa."],
                "correctAnswer": "Siya ay isang magandang halimbawa."
            },
            {
                "question": "Ano ang tinutukoy sa kuwento?",
                "options": ["ang mga tungkulin ng mga Muslim", "ang pagmamahalan sa pamilya", "ang pamamasyal ni Tito Abdul", "ang kagandahan ng Mecca"],
                "correctAnswer": "ang mga tungkulin ng mga Muslim"
            }
        ]
    },
    {
        "title": "Tagtuyot Hatid ng El Niño",
        "content": "Tagtuyot ang hatid ng El Niño. Dahil dito, bumababa ang water level at nagkukulang sa suplay ng tubig sa mga anyong tubig, gaya ng mga ilog at batis. Nagkukulang din sa suplay ng tubig sa mga imbakan gaya ng La Mesa Dam na matatagpuan sa Lungsod Quezon at Angat Dam sa Bulacan. Ang mga ito ang pinagkukunan ng tubig sa Kamaynilaan at sa mga karatig probinsya nito.\nMalaki ang epektong dulot ng El Niño sa buhay ng tao. Kukulangin ang suplay ng tubig na inumin, pati na rin ang gagamiting tubig para sa iba pang pangangailangan.\nHindi lamang tao ang mahihirapan sa epekto ng tagtuyot. Kung kulang ang tubig, magkakasakit ang mga hayop at maaari rin silang mamatay.\nAng tubig ay kailangan din ng mga halaman at kagubatan. Maraming apektadong taniman kung kulang ang patubig. Dahil sa sobrang init, maaaring mag-apoy ang mga puno na nagdudulot ng sunog.\n\nIsang malaking tulong sa panahon ng El Niño ay ang pagtitipid ng tubig.\nIwasang aksayahin at gamitin ang tubig sa hindi mahahalagang bagay.",
        "type": "pretest",
        "gradeLevel": "Grade 5",
        "set": "Set A",
        "quizzes": [
            {
                "question": "Ano ang nangyayari kapag may El Niño?",
                "options": ["tagtuyo", "red tide", "ipu-ipo", "bagyo"],
                "correctAnswer": "tagtuyo"
            },
            {
                "question": "Maliban sa tao, ano-ano pa ang maaapektuhan sa El Niño?",
                "options": ["hayop, halaman at gubat", "hangin, lupa at buhangin", "bato, semento at tubig", "ulap, araw at bituin"],
                "correctAnswer": "hayop, halaman at gubat"
            },
            {
                "question": "Ano ang HINDI nagaganap kapag tagtuyot?",
                "options": ["pag-ihip ng hangin", "pag-ulan", "pagdilim", "pag-araw"],
                "correctAnswer": "pag-ulan"
            },
            {
                "question": "Ano kaya ang nararamdaman ng mga tao kapag El Nino?",
                "options": ["giniginaw", "masigla", "naiinitan", "nanlalamig"],
                "correctAnswer": "naiinitan"
            },
            {
                "question": "Bakit kaya maaaring maraming magutom kapag tagtuyot?",
                "options": ["Magkakasakit ang mga tao.", "Tatamarin magluto ang mga tao.", "Kukulangin ang tubig sa pagluluto.", "Hindi makapagtatanim ang magsasaka."],
                "correctAnswer": "Hindi makapagtatanim ang magsasaka."
            },
            {
                "question": "Bakit kayang mahalaga na mabasa at maintindihan ang talatang ito?",
                "options": ["para maiwasan ang pagkakaroon ng El Niño", "para magtulungan sa pagtitipid ng tubig", "para magkaroon ng lakas ng loob", "para hindi maging handa sa tag-ulan"],
                "correctAnswer": "para magtulungan sa pagtitipid ng tubig"
            },
            {
                "question": "Ano ang HINDI nakasaad sa seleksyon?",
                "options": ["ang dahilan ng El Nino", "ang mga epekto ng El Nino", "ang maaaring gawin kapag may El Nino", "kung sino at ano ang apektado sa El Nino"],
                "correctAnswer": "ang dahilan ng El Nino"
            }
        ]
    },
    {
        "title": "Buhayin ang Kabundukan",
        "content": "Ang mga kabundukan ay isa sa magagandang tanawin sa ating kapaligiran. Taglay nito ang mga punungkahoy na nagbibigay ng ating mga pangangailangan. Makikita rito ang sari-saring mga halaman na nakalulunas ng ibang karamdaman, mga orkidyas, mga ligaw na bulaklak at mga hayop.\nAng mga punungkahoy at iba pang halaman ay tumutulong sa pagpigil ng erosyon o pagguho ng lupa dulot ng ulan o baha. Nagsisilbi rin itong watershed para sa sapat na pagdaloy ng tubig.\nSubalit marami sa mga kabundukan natin ang nanganganib. Ang dating lugar na pinamumugaran ng mga ibon at mga ligaw na bulaklak ay unti-unti nang nasisira. Dahil sa patuloy na pagputol ng mga punungkahoy, marami na ang nagaganap na mga kalamidad tulad ng biglaang pagbaha sa iba’t ibang pook.\nSa pangunguna at pakikipagtulungan ng Department of Environment and Natural Resources (DENR), ang ahensya ng bansa na tumutugon sa pag-aalaga ng kapaligiran at kalikasan, ang pagkasira ng kabundukan ay nabigyan ng solusyon. Ang reforestation o muling pagtatanim ng puno kapalit ng mga pinutol o namatay na mga puno ay isa sa mga programa ng DENR. Maraming tao ang natuwa dito at inaasahan nila na darating ang panahon na manunumbalik ang kagandahan at kasaganaan ng mga kabundukan.",
        "type": "pretest",
        "gradeLevel": "Grade 6",
        "set": "Set A",
        "quizzes": [
            {
                "question": "Ano ang nakukuha sa kabundukan na tumutugon sa pangangailangan ng tao?",
                "options": ["bato", "ginto", "lupa", "punungkahoy"],
                "correctAnswer": "punungkahoy"
            },
            {
                "question": "Ano ang ginagawa sa punungkahoy na nagiging sanhi ng mga kalamidad?",
                "options": ["pagsunog ng puno", "pagtanim ng puno", "pagputol ng puno", "pagparami ng puno"],
                "correctAnswer": "pagputol ng puno"
            },
            {
                "question": "Bakit nawawalan ng hayop sa kabundukan kapag nagpuputol ng mga puno?",
                "options": ["Naliligaw sila sa gubat.", "Wala silang matitirahan.", "Nakakain sila ng ibang hayop.", "Madali silang nahuhuli ng tao."],
                "correctAnswer": "Wala silang matitirahan."
            },
            {
                "question": "Ano ang salitang kasingkahuluganng pagguho ng lupa? (Literal)",
                "options": ["erosyon", "kalamidad", "reforestation", "watershed"],
                "correctAnswer": "erosyon"
            },
            {
                "question": "Ano kayang ugali ang ipinapakita ng mga taong patuloy na nagpuputol ng mga puno ng kagubatan?",
                "options": ["mapagbigay", "masipag", "sakim", "tamad"],
                "correctAnswer": "sakim"
            },
            {
                "question": "Ano ang magandang maidudulot ng reforestation?",
                "options": ["maiiwasan ang tagtuyot", "maiiwasan ang pagbaha", "maiiwasan ang pag-ulan", "maiiwasan ang pagbagyo"],
                "correctAnswer": "maiiwasan ang pagbaha"
            },
            {
                "question": "Piliin ang angkop na kadugtong ng slogan na “Buhayin ang Kabundukan: ______________________________________”",
                "options": ["Magtanim ng Mga Puno", "Ilagay sa Hawla Ang Mga Ibon", "Ilipat sa Kapatagan Ang Mga Halaman", "Iwasan ang Pagkuha ng Mga Bulaklak"],
                "correctAnswer": "Magtanim ng Mga Puno"
            },
            {
                "question": "Ano ang koneksyon ng pagputol ng mga puno sa kagubatan sa pagbaha sa kapatagan?",
                "options": ["Sa kabatagan na babagsak ang ulan.", "Kapag wala ng puno, madalas na ang pag-ulan.", "Wala ng mga hayop na magbabantay sa daloy ng tubig.", "Wala nang pipigil sa pagdaloy ng tubig mula sa kabundukan."],
                "correctAnswer": "Wala nang pipigil sa pagdaloy ng tubig mula sa kabundukan."
            }
        ]
    },
    {
        "title": "Pagpapala sa Pangingisda",
        "content": "Ang ating bansa ay napaliligiran ng malawak na karagatan. Sagana ito sa iba’t ibang uri ng isda. Kaya marami sa mga Pilipino ay pangingisda ang ikinabubuhay.\nSa pakikipagtulungan ng mga pribadong kumpanya ng pangingisda, ang ating pamahalaan ay nag-eeksport sa Hongkong at Taiwan. Iba’t ibang uri ng isda ang dinadala natin sa mga bansang ito tulad ng tuna at lapu-lapu. Malaki ang naitutulong nito sa hanapbuhay ng ating mga mangingisda. Subalit ang kasaganahang ito ay malimit na inaabuso. May mga mangingisdang gumagamit ng mga pampasabog at lasong kemikal para makahuli ng maraming isda. Namamatay ang maliliit na isda na dapat sana ay lumaki at dumami pa. Ang iba naman ay sinisira ang mga coral reefs na tirahan ng mga isda.\nAng Kagawaran ng Agrikultura sa pangunguna ng Bureau of Fisheries and Aquatic Resources (BFAR) ay patuloy na gumagawa ng mga hakbang para masugpo ang mga mangingisdang lumalabag sa batas pagdating sa paraan ng pangingisda. Ang BFAR ay nagsasagawa ng mga proyekto na magpapaunlad sa produksyon ng isda. Kasama rito ang pagbabawal ng pangingisda na nakasisira sa coral reefs, ang pagbubuo ng mga artificial reefs, at pagmomonitor ng red tide sa iba’t ibang karagatan sa buong bansa.\nMalaking bahagi ng ekonomiya ang nagbubuhat sa sektor ng mga mangingisda. Maraming tao rin ang nakikinabang sa pagtatrabaho sa industriya ng pangingisda tulad ng fish marketing, fish processing, net making, boat-building at fish trading. Ito ang mga dahilan kung bakit kailangang alagaan ang industriyang ito.",
        "type": "pretest",
        "gradeLevel": "Grade 7",
        "set": "Set A",
        "quizzes": [
            {
                "question": "Ano-anong isda ang ipinapadala sa ibang bansa?",
                "options": ["dilis at tawilis", "tilapia at bangus", "tuna at lapu-lapu", "galunggong at bisugo"],
                "correctAnswer": "tuna at lapu-lapu"
            },
            {
                "question": "Alin sa sumusunod ang paraan ng pangingisda na ipinagbabawal? (Paghinuha)",
                "options": ["pamimingwit", "paggamit ng lambat", "ang paraang pagbubuslo", "paggamit ng pampasabog"],
                "correctAnswer": "paggamit ng pampasabog"
            },
            {
                "question": "Anong tanggapan ang nangunguna sa pagsugpo sa labag na batas na paraan ng pangingisda?",
                "options": ["Bureau of Food and Drug", "Metro Manila Development Authority", "Bureau of Fisheries and Aquatic Resources", "Department of Energy and Natural Resources"],
                "correctAnswer": "Bureau of Fisheries and Aquatic Resources"
            },
            {
                "question": "Bakit maraming Pilipinong may hanapbuhay na pangingisda?",
                "options": ["Magaling lumangoy ang mga Pilipino.", "Maraming hindi nais magtrabaho sa taniman.", "Walang ibang makuhang trabaho ang mga Pilipino.", "Napaliligiran ng malawak na karagatan ang Pilipinas."],
                "correctAnswer": "Napaliligiran ng malawak na karagatan ang Pilipinas."
            },
            {
                "question": "Ano kaya ang masamang epekto ng paggamit ng pampasabog at lason sa pangingisda sa tao?",
                "options": ["Natatakot ang mga isda.", "Hindi na lumalaki ang mga isda.", "Wala nang makakaing isda ang mga tao.", "Namamatay ang maliliit at batang isda."],
                "correctAnswer": "Namamatay ang maliliit at batang isda."
            },
            {
                "question": "Ano ang maaaring mangyari kung hindi ipagbawal ang maling paraan ng pangingisda?",
                "options": ["Mauubos ang mga isda sa dagat.", "Mawawalan ng hanapbuhay ang mga mangingisda.", "Mata-takot na gumamit ng pampasabog ang mga tao.", "Maraming gagamit ng tamang paraan ng pangingisda."],
                "correctAnswer": "Mauubos ang mga isda sa dagat."
            },
            {
                "question": "Anong ugali ang ipinakikita ng mga mangingisdang patuloy na gumagamit ng maling paraan ng pangingisda?",
                "options": ["mahilig sa gulo", "matigas ang ulo", "malikhain sa trabaho", "masipag maghanapbuhay"],
                "correctAnswer": "matigas ang ulo"
            },
            {
                "question": "Ano ang layunin ng manunulat ng seleksyon? (Pagsusuri)\nNais ng manunulat na ________________________________________.",
                "options": ["ipagmalaki ang Pilipinas bilang isang mayamang bansa", "makilala ang Pilipinas bilang magandang pinagkukunan ng isda", "ipaubaya sa pamahalaan ang pag-aalaga sa mga katubigan ng bansa", "malaman ng tao na sa bawat gawain ay may kaakibat na responsibilidad"],
                "correctAnswer": "malaman ng tao na sa bawat gawain ay may kaakibat na responsibilidad"
            }
        ]
    },
    {
        "title": "Sa Lawa",
        "content": "Pumunta sa lawa si Tito.\nKasama niya si Lina sa lawa.\nMalayo ang lawa.\nNakita nila ang palaka sa lawa.\nNakita nila ang bibe sa lawa.\nNakita rin nila ang buwaya.\nNaku! Ang laki ng buwaya!",
        "type": "pretest",
        "gradeLevel": "Grade 1",
        "set": "Set B",
        "quizzes": [
            {
                "question": "Sino-sino ang nasa lawa?",
                "options": ["sina Tito at Lina", "sina Tito at Tita", "si Lina"],
                "correctAnswer": "sina Tito at Lina"
            },
            {
                "question": "Ano-ano ang mga nakita niya sa lawa?",
                "options": ["mga halaman", "mga insekto", "mga hayop"],
                "correctAnswer": "mga hayop"
            },
            {
                "question": "Ano ang hitsura ng buwaya?",
                "options": ["maliit", "malaki", "maganda"],
                "correctAnswer": "malaki"
            },
            {
                "question": "Ano ang naramdaman ni Tito nang makita ang buwaya?",
                "options": ["nagulat", "nagalit", "nalungkot"],
                "correctAnswer": "nagulat"
            },
            {
                "question": "Ano kaya ang ginawa ni Tito?",
                "options": ["lumangoy", "naglaro", "sumigaw"],
                "correctAnswer": "sumigaw"
            }
        ]
    },
    {
        "title": "Si Dilis at Si Pating",
        "content": "Sa dagat nakatira si Dilis. Kalaro niya ang mga maliliit na isda. Sila ay masaya.\nNasa dagat din si Pating. Malaki at mabangis ito. Takot si Dilis at ang mga kalaro niyang isda kay Pating.\nMinsan, hindi kaagad nakita ni Dilis si Pating. Gutom na gutom na si Pating.\nMabilis si Dilis. Nagtago siya sa ilalim ng korales. Hindi siya nakain ni Pating. Matalino talaga si Dilis.\nDapat maging matalino para matulungan ang sarili.",
        "type": "pretest",
        "gradeLevel": "Grade 2",
        "set": "Set B",
        "quizzes": [
            {
                "question": "Saan nakatira si Dilis?",
                "options": ["sa dagat", "sa ilog", "sa sapa"],
                "correctAnswer": "sa dagat"
            },
            {
                "question": "Ano ang sama-samang ginagawa nina Dilis at ng maliliit na isda?",
                "options": ["namamasyal", "nagtatago", "naglalaro"],
                "correctAnswer": "naglalaro"
            },
            {
                "question": "Bakit takot si Dilis kay Pating?",
                "options": ["Baka awayin siya ni Pating.", "Maaari siyang kainin ni Pating.", "Baka agawan siya ni Pating ng pagkain."],
                "correctAnswer": "Maaari siyang kainin ni Pating."
            },
            {
                "question": "Paano ipinakita ni Dilis ang pagiging matalino?",
                "options": ["Mabilis siyang nakapagtago sa korales.", "Tinulungan niya ang mga maliliit na isda.", "Hindi siya nakipaglaro kay Pating."],
                "correctAnswer": "Mabilis siyang nakapagtago sa korales."
            },
            {
                "question": "Alin sa sumusunod ang isa pang magandang pamagat ng kuwento?",
                "options": ["Sa Ilalim ng Dagat", "Ang Gutom na Pating", "Si Dilis, ang Mabangis na Isda"],
                "correctAnswer": "Sa Ilalim ng Dagat"
            }
        ]
    },
    {
        "title": "Maliit na Duhat, Malaking Pakwan",
        "content": "Nasa likod-bahay si Pido. Pumunta siya sa silong ng punong duhat. Sabi niya, “Ang laki ng punong ito, ang liit naman ng bunga.”\nNakita rin niya sa may taniman ang halaman ng pakwan, “Ang pakwan na gumagapang lamang sa lupa, kay laki ng bunga.” dagdag niyang sinabi.\n“Mali kaya ang pagkagawa ng Diyos?”\nHabang iniisip niya ang tanong sa sarili, biglang nalaglag ang isang bunga ng duhat. “Aray!” sigaw niya. “Tama pala ang Diyos. Kung kasinlaki ng pakwan ang duhat, may bukol ang ulo ko ngayon,” pailing na sinabi ni Pido.",
        "type": "pretest",
        "gradeLevel": "Grade 3",
        "set": "Set B",
        "quizzes": [
            {
                "question": "Sino ang nasa silong ng puno?",
                "options": ["Diday", "Pandoy", "Pido"],
                "correctAnswer": "Pido"
            },
            {
                "question": "Ano ang ipinagtataka ni Pido tungkol sa puno ng duhat?",
                "options": ["malaki ang puno maliit ang bunga", "ang hugis ng prutas sa puno", "ang kulay ng bunga ng punong duhat"],
                "correctAnswer": "malaki ang puno maliit ang bunga"
            },
            {
                "question": "Saan nalaglag ang bunga ng duhat?",
                "options": ["sa sahig", "sa basket", "sa ulo ni Pido"],
                "correctAnswer": "sa ulo ni Pido"
            },
            {
                "question": "Ano ang naramdaman ni Pido nang mahulugan siya ng bunga ng duhat?",
                "options": ["nagalit", "natakot", "nasaktan"],
                "correctAnswer": "nasaktan"
            },
            {
                "question": "Ano ang mangyayari kay Pido kung malaki ang bunga ng duhat?",
                "options": ["mapipilayan", "mabubukulan", "magkakasakit"],
                "correctAnswer": "mabubukulan"
            },
            {
                "question": "Ano ang katangian ng Diyos ang naisip ni Pido?",
                "options": ["maalalahanin", "matalino", "masipag"],
                "correctAnswer": "matalino"
            }
        ]
    },
    {
        "title": "Parol sa May Bintana",
        "content": "Disyembre na naman.\nTumulo ang luha sa mga mata ni Julia. Nakita niya ang nakasabit na parol sa sulok ng kanilang bahay. Gawa iyon ng kanilang ama. Nilagyan niya ng ilaw ang parol at isinabit ito sa may bintana.\nKay ganda ng parol! Tumayo si Julia at hinawakan ang parol. Tandangtanda niya pa ang kasiyahan nilang mag-anak noong nakaraang Pasko.\n“Huwag kayong malulungkot,” sabi ng kanyang ama. “Aalis ako upang mabigyan kayo ng magandang kinabukasan.”\n“Ingatan ninyo ang parol. Magsisilbi itong gabay sa inyong mga gagawin,” paliwanag ng ama noong bago umalis sa kanilang bahay.\n“Tama si Itay. Kahit nasa malayo siya, ang parol na ito ang magpapaalala sa amin sa kanya at sa kanyang mga pangaral.”\nParang napawi ang lungkot ni Julia, napangiti siya sabay kuha sa parol.",
        "type": "pretest",
        "gradeLevel": "Grade 4",
        "set": "Set B",
        "quizzes": [
            {
                "question": "Anong mahalagang araw ang malapit nang sumapit?",
                "options": ["Pasko", "Mahal na Araw", "Araw ng mga Puso"],
                "correctAnswer": "Pasko"
            },
            {
                "question": "Ano ang unang naramdaman ni Julia nang makita niya ang parol?",
                "options": ["nagalit", "nalungkot", "nasasabik"],
                "correctAnswer": "nalungkot"
            },
            {
                "question": "Sino ang naalala ni Julia tuwing makikita ang parol?",
                "options": ["Ina", "Itay", "kapatid"],
                "correctAnswer": "Itay"
            },
            {
                "question": "Ano ang ibig sabihin ng ama ni Julia nang sinabi niya ang “Ingatan ninyo ang parol, magsisilbi itong gabay sa inyong mga gagawin”?",
                "options": ["Huwag pabayaang masira ang parol.", "Ang parol ang magpapaalala sa mga habilin ng ama.", "Ang ilaw nito ang magpapaliwanag sa mga gawain nila."],
                "correctAnswer": "Ang parol ang magpapaalala sa mga habilin ng ama."
            },
            {
                "question": "Ano kaya ang ginagawa ng tatay ni Julia sa malayong lugar?",
                "options": ["nag-aaral", "nagtatrabaho", "namamasyal"],
                "correctAnswer": "nagtatrabaho"
            },
            {
                "question": "Bakit napangiti si Julia sa katapusan ng kuwento?",
                "options": ["dahil may ilaw ang parol", "dahil naintindihan niya ang ama niya", "dahil malapit nang umuwi ang ama niya"],
                "correctAnswer": "dahil naintindihan niya ang ama niya"
            }
        ]
    },
    {
        "title": "Pista ng Bulaklak",
        "content": "Tuwing Pebrero, ipinagdiriwang ang pista ng mga bulaklak sa Lungsod ng Baguio. Kilala rin ito sa tawag na Pista ng Panagbenga. Ang Panagbenga ay salitang galing sa Cordillera na ang kahulugan ay panahon ng pagbukadkad ng bulaklak. Binibigyang halaga sa pistang ito ang naggagandahang bulaklak kung saan kilala ang lungsod na ito.\nNagsimula ang pagdiriwang ng Panagbenga noong 1995. Isinagawa ng pistang ito para maiangat muli ang Lungsod ng Baguio mula sa malagim na lindol noong 1990.\nMaraming gawain ang makikita sa pagdiriwang ng Panagbenga.\nAng pinakasikat at inaabangang gawain tuwing pista ng bulaklak ay ang parada. Kasama sa paradang ito ay sayawan sa kalsada at pagtugtog ng mga banda. Pinakabida sa paradang ito ang mga higanteng karosa na puno ng mga magaganda at mababangong bulaklak. Sa paggawa ng karosang ito, ipinakikita ng mga Pilipino ang kanilang pagiging malikhain at pagiging matulungin. Ipinaparada ang mga ito sa malalaking kalsada ng lungsod.\nMaraming mga taong galing pa sa iba’t ibang bahagi ng Pilipinas ang dumadayo sa Baguio upang mapanood ito.",
        "type": "pretest",
        "gradeLevel": "Grade 5",
        "set": "Set B",
        "quizzes": [
            {
                "question": "Anong buwan nagaganap ang Pista ng Panagbenga?",
                "options": ["unang buwan ng taon", "ikalawang buwan ng taon", "ikatlong buwan ng taon", "huling buwan ng taon"],
                "correctAnswer": "ikalawang buwan ng taon"
            },
            {
                "question": "Kailan nagsimula ang pagdiriwang na ito?",
                "options": ["1908", "1990", "1995", "2012"],
                "correctAnswer": "1995"
            },
            {
                "question": "Ano ang inaabangang gawain sa pistang ito?",
                "options": ["tugtog ng banda", "palaro sa mga bata", "parada ng bulaklak", "sayawan sa kalsada"],
                "correctAnswer": "parada ng bulaklak"
            },
            {
                "question": "Ano-anong katangian ng mga Pilipino ang ipinakikita sa seleksyon?",
                "options": ["pagiging matalino at palaisip", "pagiging masipag at matulungin", "pagiging malikhain at masayahin", "pagiging maalalahanin at palakaibigan"],
                "correctAnswer": "pagiging masipag at matulungin"
            },
            {
                "question": "Bakit sinimulan ang Pista ng Panagbenga?",
                "options": ["para maging sikat ang lalawigan", "para hindi masayang ang mga bulaklak", "para maiwasan ang pag-ulit ng lindol noong 1990", "para mapaunlad muli ang lugar matapos ang lindol noong 1990"],
                "correctAnswer": "para mapaunlad muli ang lugar matapos ang lindol noong 1990"
            },
            {
                "question": "Bakit kaya maraming tao ang dumadayo sa pagdiriwang na ito?",
                "options": ["ayaw nilang pumasok sa paaralan", "gusto nilang makakita ng mga turista", "maraming gustong makarating sa Baguio", "Nais nilang makita ang mga karosa ng bulaklak"],
                "correctAnswer": "Nais nilang makita ang mga karosa ng bulaklak"
            },
            {
                "question": "Ano ang tinutukoy sa seleksyon?",
                "options": ["ang kagandahan ng Lungsod ng Baguio", "ang kasaysayan ng Lungsod ng Baguio", "ang isang kilalang pista sa Baguio", "ang ugali ng mga tao sa Baguio"],
                "correctAnswer": "ang isang kilalang pista sa Baguio"
            }
        ]
    },
    {
        "title": "Ang Puerto Princesa Underground River",
        "content": "Ang Puerto Princesa Subterranean River National Park (PPSRNP) ay makikita sa Palawan. Ito ay matatagpuan sa hilagang kanlurang bahagi ng Puerto Princesa.\nIpinakikita sa tanyag na pook na ito ang mga higanteng limestone na nasa kuwebang pinalolooban ng ilog. Iba’t ibang kamangha-manghang hugis ang nabuo mula sa mga limestone sa loob ng kuweba. Ang ilog ay tinatayang 8.2 kilometro ang haba at ito ay tumutuloy sa dagat. Ang kagandahan nito ang dahilan kung bakit nakilala ang Puerto Princesa Underground River bilang isa sa Pitong New Wonders of Nature.\nMakikita sa paligid ng ilog ang kabundukan at kagubatan. Ang makapal na kagubatan ang nagsisilbing tahanan ng ilang hayop na pambihira at endangered. Sa baybayin naman nito makikita ang halamang bakawan at mga coral reefs.\nMula nang maitalaga ang Puerto Princesa Underground River bilang isa sa Pitong New Wonders of Nature, dumami na ang mga taong gustong makita ito, maging Pilipino man o dayuhan.\nMaliban sa pagsakay sa bangka upang makita ang limestones sa loob ng kuweba, marami pang maaaring gawin dito na ikasasaya ng mga turista. Kinagigiliwan ng mga bisita rito ang jungle trekking, wildlife watching, mangrove forest tour at ang paglangoy sa tabing-dagat na puti ang buhangin.",
        "type": "pretest",
        "gradeLevel": "Grade 6",
        "set": "Set B",
        "quizzes": [
            {
                "question": "Saang lalawigan matatagpuan ang Underground River?",
                "options": ["sa Bicol", "sa Iloilo", "sa Mindoro", "sa Palawan"],
                "correctAnswer": "sa Palawan"
            },
            {
                "question": "Ano ang kamangha-manghang tingnan sa loob ng kuweba ng Underground River?",
                "options": ["ang napakalinaw na tubig-ilog", "ang mga hayop sa loob ng kuweba", "ang iba't-ibang hugis ng limestone", "ang mga halaman sa loob ng kuweba"],
                "correctAnswer": "ang iba't-ibang hugis ng limestone"
            },
            {
                "question": "Bakit kaya dumami ang turistang bumibisita sa Underground River?",
                "options": ["madali lang puntahan ito", "nakamamangha ang tubig sa ilog", "naging tanyag ito sa buong mundo", "pambihira ang hugis ng kuweba sa ilog"],
                "correctAnswer": "naging tanyag ito sa buong mundo"
            },
            {
                "question": "Bakit dapat alagaan ang mga hayop na makikita sa kagubatan sa paligid ng Underground River?",
                "options": ["dahil ito ay endangered at pambihira", "dahil may karapatan itong mabuhay", "dahil makukulay ito at magaganda", "dahil maaari itong pagkakitaan"],
                "correctAnswer": "dahil ito ay endangered at pambihira"
            },
            {
                "question": "Ano kaya ang kailangang gawin ng lokal na pamahalaan para sa Underground River?",
                "options": ["magtayo ng iba’t ibang water sports dito", "lagyan ito ng mga bahay-bakasyunan", "pangalagaan at proteksyonan ito", "pagbabawalan ang bumibisita rito"],
                "correctAnswer": "pangalagaan at proteksyonan ito"
            },
            {
                "question": "Ayon sa seleksyon, ano pa ang maaaring gawin ng mga pumupunta sa Underground River maliban sa pagpasok sa kuweba?",
                "options": ["mangisda sa ilog", "maglaro sa kuweba", "lumangoy sa tabindagat", "kumain ng masasarap na pagkain"],
                "correctAnswer": "lumangoy sa tabindagat"
            },
            {
                "question": "Ano kaya ang naramdaman ng mga Pilipino nang mahirang ang Underground River bilang isa sa Pitong New Wonders of Nature?",
                "options": ["Nagulat dahil hindi ito dapat nangyari.", "Natuwa dahil maipagmamalaki nila ito.", "Nalito at nakipagtalo kung kailangang puntahan ito.", "Nag-alala dahil magiging mahal na ang pagpunta rito."],
                "correctAnswer": "Natuwa dahil maipagmamalaki nila ito."
            },
            {
                "question": "Alin sa sumusunod ang pinakamagandang sabihin sa mga turistang bumibisita sa Underground River? (Pagsusuri)",
                "options": ["Kaunting halaman lamang ang kunin mula dito.", "Ingatan ang kapaligiran sa Underground River.", "Iwasang mag-ingay habang nasa loob ng kuweba.", "Ingatan ang pagkuha ng litrato sa Underground River."],
                "correctAnswer": "Ingatan ang kapaligiran sa Underground River."
            }
        ]
    },
   
    {
        "title": "Kasaysayan ng Tacloban",
        "content": "Ang Tacloban ay kabisera ng lalawigan ng Leyte. Ang Leyte ay matatagpuan sa Rehiyon 8 ng Pilipinas na bahagi ng Silangang Visayas.\nAng Tacloban ay unang nakilala bilang Kankabatok, na ang ibig sabihin ay “pag-aari ng mga Kabatok.” Kabatok ang tawag sa mga unang naninirahan dito. Mayaman sa yamang tubig ang lugar na ito. May ginagamit silang isang uri ng basket na panghuli sa mga isda at alimango. Ang tawag nila dito ay “Taklub.” Kapag may mga darayo sa lugar, ang sinasabi nila ay pupunta sila sa “tarakluban.” Pagtagal ay tinawag din itong Tacloban.\nAng Tacloban ay nakilala dahil sa ginampanang papel nito noong Ikalawang Digmaang Pandaigdig. Dito naganap ang tanyag na pagbabalik ni General Macarthur. Naganap ito sa baybayin ng “White Beach” ng Tacloban.\nDito rin nagtayo ng base militar ang pwersa ng mga Amerikano at ang bayang ito ay ang unang napalaya mula sa mga puwersa ng mga Hapon.\nNaging pansamantala itong kapital ng Pilipinas habang ang Maynila ay nasa kapangyarihan pa ng mga Hapon.\nSa syudad na ito nanggaling ang dating Unang Ginang ng Pilipinas na si Imelda Romualdez Marcos. Ang Pamilya Romualdez ay isa sa mga kilalang pamilyang politiko sa lugar. Ang pangalan ng paliparan sa Tacloban ay Romualdez airport. Kakaunti lang ang nakakaalam kung kailan naging munisipalidad ang Tacloban dahil ang mga dokumentong nakapagpapatunay rito ay nasira ng bagyo. Pero marami ang naniniwala na ang Tacloban ay opisyal na naiproklamang munisipalidad noong 1770.",
        "type": "pretest",
        "gradeLevel": "Grade 7",
        "set": "Set B",
        "quizzes": [
            {
                "question": "Saan matatagpuan ang Tacloban?",
                "options": ["sa Kanlurang Visayas", "sa Silangang Visayas", "sa Hilagang Visayas", "sa Timog Visayas"],
                "correctAnswer": "sa Silangang Visayas"
            },
            {
                "question": "Sino ang kilalang tao na dumako sa Tacloban noong Ikalawang Digmaang pandaigdig?",
                "options": ["Imelda Marcos", "Emilio Aguinaldo", "Imelda Romualdez", "Douglas MacArthur"],
                "correctAnswer": "Douglas MacArthur"
            },
            {
                "question": "Sino ang pangulo ng Pilipinas na nakapangasawa ng isang taga-Tacloban?",
                "options": ["Pangulong Gloria Arroyo", "Pangulong Fidel Ramos", "Pangulong Ferdinand Marcos", "Pangulong Diosdado Macapagal"],
                "correctAnswer": "Pangulong Ferdinand Marcos"
            },
            {
                "question": "Bakit naging kabisera ng Pilipinas ang Tacloban?",
                "options": ["Marami ang may ayaw sa Maynila.", "Maraming tanyag na tao sa Tacloban.", "Ang Maynila ay sinasakop pa ng mga Hapon.", "Maraming makapangyarihang politiko sa Tacloban."],
                "correctAnswer": "Ang Maynila ay sinasakop pa ng mga Hapon."
            },
            {
                "question": "Bakit kaya unang napalaya mula sa puwersa ng Hapon ang Tacloban?",
                "options": ["Takot ang mga Hapon sa mga taga-Tacloban.", "Kilala kasi ang mga taga-Tacloban na matatapang.", "Walang maraming sundalong Hapon sa Tacloban.", "Mayroong base militar ng mga Amerikano ang Tacloban."],
                "correctAnswer": "Mayroong base militar ng mga Amerikano ang Tacloban."
            },
            {
                "question": "Ano ang ikinabubuhay ng mga taong taga-Tacloban?",
                "options": ["pangingisda", "pagtatanim", "pagtitinda", "pagtutuba"],
                "correctAnswer": "pangingisda"
            },
            {
                "question": "Bakit kaya pinangalanang Romualdez airport ang paliparan sa Tacloban?",
                "options": ["Malaki ang naitulong ng Romualdez sa lugar.", "Malaki ang pamilya ng Romualdez sa Tacloban.", "Maraming Romualdez ang nasa lokal na gobyerno.", "Marami sa Romualdez ang madalas sumakay sa eroplano."],
                "correctAnswer": "Malaki ang naitulong ng Romualdez sa lugar."
            },
            {
                "question": "Ano ang layunin ng sumulat ng seleksyon?",
                "options": ["Nais nitong hikayatin ang mambabasa na bumisita sa Tacloban.", "Gusto nitong ipaalam ang pinagmulan at naganap sa Tacloban.", "Hangad nitong maghatid ng aliw sa mambabasa.", "Hatid nito ang isang mabuting halimbawa."],
                "correctAnswer": "Gusto nitong ipaalam ang pinagmulan at naganap sa Tacloban."
            }
        ]
    },

    {
        "title": "Ang Mesa ni Lupe",
        "content": "Ito ang mesa ni Lupe.\nMalaki ang mesa ni Lupe.\nNasa mesa ang relo ni Lupe.\nMay baso at tasa sa mesa ni Lupe.\nMay bola rin sa mesa.\nNaku! Ang bola!\nTumama ang bola sa baso.\nHala! Nabasa ang relo sa mesa!",
        "type": "pretest",
        "gradeLevel": "Grade 1",
        "set": "Set C",
        "quizzes": [
            {
                "question": "Kanino ang mesa?",
                "options": ["kay Lupe", "kay Nanay", "kay Lani"],
                "correctAnswer": "kay Lupe"
            },
            {
                "question": "Alin sa sumusunod ang wala sa mesa ni Lupe?",
                "options": ["bola", "bote", "relo"],
                "correctAnswer": "bote"
            },
            {
                "question": "Ano ang nangyari sa baso?",
                "options": ["nabasag", "nahulog sa sahig ang baso", "tumapon ang lamang tubig"],
                "correctAnswer": "tumapon ang lamang tubig"
            },
            {
                "question": "Ano kaya ang mangyayari sa relo?",
                "options": ["magagasgas", "masisira", "matutunaw"],
                "correctAnswer": "masisira"
            },
            {
                "question": "Ano kaya ang naramdaman ni Lupe?",
                "options": ["nalungkot", "napagod", "nasabik"],
                "correctAnswer": "nalungkot"
            }
        ]
    },
    {
        "title": "Gitara ni Lana",
        "content": "May gitara si Lana.\nMaganda ang gitara ni Lana.\nBago ang gitara niya.\nKulay pula at may bulaklak na puti ito.\nBigay ito ni Tita Ana.\nBinigay niya ito noong kaarawan ni Lana.\nLaging dala ni Lana ang gitara.\nLagi rin niyang pinatutugtog ito.\nHawak ni Lana ang gitara habang naglalakad.\nNaglalakad siya papunta sa parke.\nTumama ang paa ni Lana sa isang malaking bato.\nAaaa! Nahulog sa bato ang gitara!",
        "type": "pretest",
        "gradeLevel": "Grade 2",
        "set": "Set C",
        "quizzes": [
            {
                "question": "Sino ang may gitara?",
                "options": ["si Lana", "si Mila", "si Tita Ana"],
                "correctAnswer": "si Lana"
            },
            {
                "question": "Kanino galing ang gitara?",
                "options": ["sa isang kalaro", "sa isang kaklase", "sa isang kamag-anak"],
                "correctAnswer": "sa isang kamag-anak"
            },
            {
                "question": "Ano ang kulay ng kanyang gitara?",
                "options": ["asul", "puti", "pula"],
                "correctAnswer": "pula"
            },
            {
                "question": "Saan naganap ang kuwento?",
                "options": ["sa loob ng bahay", "sa labas ng bahay", "sa isang handaan"],
                "correctAnswer": "sa labas ng bahay"
            },
            {
                "question": "Ano kaya ang nangyari sa gitara ni Lana?",
                "options": ["nabasag", "ninakaw", "nasira"],
                "correctAnswer": "nasira"
            }
        ]
    },
    {
        "title": "Ang Matalinong Bulate",
        "content": "Umaga na sa bukirin. Maagang lumabas si Bulate. Nais niyang masikatan ng araw. Sa di kalayuan, nakita siya ni Tandang. Lumapit si Tandang upang kainin si Bulate.\nNagulat si Bulate at nag-isip nang mabilis. Biglang nagsalita si Bulate.\n“Kaibigan,” simula ni Bulate, “Bago mo ako kainin, mayroon sana akong hiling. Nais ko munang marinig ang maganda mong boses.”\nNatuwa si Tandang sa sinabi ni Bulate. Alam ni Tandang na maganda ang boses niya. Tumilaok siya nang mahaba. Ang hindi niya alam, nagtago na si Bulate sa ilalim ng lupa.",
        "type": "pretest",
        "gradeLevel": "Grade 3",
        "set": "Set C",
        "quizzes": [
            {
                "question": "Sino ang gustong masikatan ng araw?",
                "options": ["si Aso", "si Bulate", "si Tandang"],
                "correctAnswer": "si Bulate"
            },
            {
                "question": "Ano ang gustong gawin ni Tandang kay Bulate?",
                "options": ["gawing kalaro", "gawing pagkain", "gawing kaibigan"],
                "correctAnswer": "gawing pagkain"
            },
            {
                "question": "Anong salita ang ginamit para ipakitang umawit si Tandang?",
                "options": ["kumanta", "tumilaok", "sumigaw"],
                "correctAnswer": "tumilaok"
            },
            {
                "question": "Ano kaya ang nararamdaman ni Bulate nang makitang papalapit si Tandang?",
                "options": ["ninerbiyos", "nagalak", "nasabik"],
                "correctAnswer": "ninerbiyos"
            },
            {
                "question": "Anong katangian ang ipinakita ni Tandang?",
                "options": ["katalinuhan", "kayabangan", "kabutihan"],
                "correctAnswer": "kayabangan"
            },
            {
                "question": "Ano ang katangian ng Diyos ang naisip ni Bulate?",
                "options": ["maalalahanin", "matalino", "masipag"],
                "correctAnswer": "matalino"
            }
        ]
    },
    {
        "title": "Bakasyon ni Herber",
        "content": "Isinama si Heber ng kanyang Tito Mar sa Rizal upang makapagbakasyon. Masayang-masaya siya dahil nakita niya sa unang pagkakataon ang Pista ng mga Higantes. Ang pistang ito ay naganap kahapon, ika-23 ng Nobyembre. Ginugunita sa pistang ito ang patron ng mga mangingisda na si San Clemente.\nPinakatampok sa pista ang matatangkad na tau-tauhang yari sa papel. Dinamitan at nilagyan ng makukulay na palamuti upang mas maging kaakit-akit sa manonood. Ang mga higante ay karaniwang may taas na apat hanggang limang talampakan o sampu hanggang labindalawang talampakan. Ang mga deboto naman ay nakasuot ng damit-mangingisda.\nHinatiran ni Heber ang camera ni Tito Mar at kumuha siya ng maraming litrato. Gusto niyang ipakita ang mga litrato sa kanyang mga magulang. Ipakikita rin niya ang mga ito sa kanyang mga kaibigan at kaklase. Hinding hindi niya makalilimutan ang araw na ito.",
        "type": "pretest",
        "gradeLevel": "Grade 4",
        "set": "Set C",
        "quizzes": [
            {
                "question": "Kanino sumama si Heber upang magbakasyon?",
                "options": ["kay Rizal", "kay Tito Mar", "sa mga higante"],
                "correctAnswer": "kay Tito Mar"
            },
            {
                "question": "Aling salita ang ginamit na ang kahulugan ay dekorasyon?",
                "options": ["kaakit-akit", "palamuti", "makukulay"],
                "correctAnswer": "palamuti"
            },
            {
                "question": "Anong petsa kaya isinulat ang kuwento?",
                "options": ["Nobyembre 24", "Nobyembre 23", "Nobyembre 25"],
                "correctAnswer": "Nobyembre 24"
            },
            {
                "question": "Paano inilalarawan sa kuwento ang higante?",
                "options": ["matangkad na tau-tauhang yari sa papel", "maitim, mahaba at magulo ang buhok, salbahe", "matangkad, malaki ang katawan at malakas magsalita"],
                "correctAnswer": "matangkad na tau-tauhang yari sa papel"
            },
            {
                "question": "Alin kaya sa sumusunod ang produkto sa Rizal?",
                "options": ["isda", "palay", "perlas"],
                "correctAnswer": "isda"
            },
            {
                "question": "Bakit kaya gusto niyang ipakita ang mga litrato sa kanyang mga magulang at kaibigan?",
                "options": ["Gusto niyang papuntahin sila sa lugar na iyon.", "Gusto niyang mainggit ang mga ibang tao sa kanya.", "Gusto niyang ibahagi ang kanyang karanasan sa kanila."],
                "correctAnswer": "Gusto niyang ibahagi ang kanyang karanasan sa kanila."
            }
        ]
    },
    {
        "title": "Biyaya ng Bulkan",
        "content": "Isa sa mga ipinagmamalaking bulkan sa bansa ang Bulkang Mayon na matatagpuan sa Albay. Tanyag ang bulkang ito dahil sa taglay nitong halos perpektong hugis apa. Dinarayo ito ng mga dayuhang bisita, maging ng mga kapwa Pilipino.\nSinasabing ang Bulkang Mayon ang pinakaaktibong bulkan sa Pilipinas dahil sa dalas ng pagsabog nito. Pinakamatindi ang pagsabog nito noong Pebrero 1, 1814, kung saan ang mga bayan sa paligid nito ay natabunan at mahigit sa 1200 katao ang namatay. Maraming nasirang bahay sa paligid ng bulkan, pati na rin ang malaking simbahan ng Cagsawa. Ang natitirang alaala na lamang ng simbahan na ito ay ang tore nito na makikitang malapit sa bulkan.\nBagamat mapanganib ang Bulkang Mayon, isa rin naman itong biyaya sa mga naninirahan malapit doon. Ang mga umagos na lupa at abo sanhi ng mga pagsabog ay nagsilbing pataba pagkalipas ng ilang taon.\nBilang patunay, itinuturing ang Albay na isa sa mga may mayayamang lupang sakahan sa rehiyon ng Bicol. Sa mga lupang sakahang ito nagbubuhat ang mga produktong abaka, niyog, palay at gulay.",
        "type": "pretest",
        "gradeLevel": "Grade 5",
        "set": "Set C",
        "quizzes": [
            {
                "question": "Saan matatagpuan ang Bulkang Mayon?",
                "options": ["Albay", "Camarines Norte", "Mindoro", "Samar"],
                "correctAnswer": "Albay"
            },
            {
                "question": "Bakit tanyag ang Bulkang Mayon?",
                "options": ["Madalas ang pagsabog nito.", "Ito ang pinakamalaking bulkan.", "Halos perpekto ang hugis apa nito.", "Matindi ang umagos na lupa at abo rito."],
                "correctAnswer": "Halos perpekto ang hugis apa nito."
            },
            {
                "question": "Bakit kaya tore lang ng Simbahan ng Cagsawa ang makikita ngayon?",
                "options": ["Ito ang pinakasikat na bahagi ng simbahan.", "Ito ang pinakabanal na bahagi ng simbahan.", "Ito ang pinakamataas na bahagi ng simbahan.", "ito ang pinakamatandang bahagi ng simbahan."],
                "correctAnswer": "Ito ang pinakamataas na bahagi ng simbahan."
            },
            {
                "question": "Ano kaya ang nararamdaman ng mga tao sa paligid ng bulkan kapag ito ay malapit nang sumabog?",
                "options": ["natutuwa", "nasasabik", "nagalit", "nangangamba"],
                "correctAnswer": "nangangamba"
            },
            {
                "question": "Alin kaya sa sumusunod na mga trabaho ang marami sa lalawigan ng Albay?",
                "options": ["inhinyero", "karpintero", "magsasaka", "mangingisda"],
                "correctAnswer": "magsasaka"
            },
            {
                "question": "Ano ang magandang naidulot ng pagsabog ng bulkan?",
                "options": ["naging malawak ng lupain", "gumanda ang hugis ng bulkan", "dumami ang bumibisita sa Mayon", "naging magandang taniman ang lupa nito"],
                "correctAnswer": "gumanda ang hugis ng bulkan"
            },
            {
                "question": "Anong aral sa buhay ang maaari nating matutunan sa talatang ito?",
                "options": ["Ang bawat trahedya ay malupit.", "Ang bawat trahedya ay may biyayang kapalit.", "Ang trahedya ang nagpapatanyag ng isang lugar.", "Ang trahedya ang nagpapabagsak sa isang lugar."],
                "correctAnswer": "Ang bawat trahedya ay may biyayang kapalit."
            }
        ]
    },
    {
        "title": "Kalabanin ang Dengue",
        "content": "Ang dengue fever ay isang kondisyong dulot ng dengue virus. Ang virus na ito ay dala ng ilang uri ng lamok gaya ng Aedes Aegypti. Kagat ng lamok na may dalang dengue virus ang sanhi ng pagkakasakit.\nPatuloy na gumagawa ng hakbang ang Department of Health para sugpuin ang dengue. Itong taon na ito, may naitala na mahigit na tatlumpung libong kaso ng dengue. Kailangan na ng gobyernong gumawa ng mga bagong paraan upang maibaba ang bilang ng mga kasong ito.\nAng isang dahilan kung bakit patuloy sa pagdami ang may sakit na dengue ay dahil binibigyan ng pagkakataon ang mga lamok na mabuhay sa paligid. Kailangan ng pakikipagtulungan ng lahat sa mga simpleng gawaing makaiiwas sa sakit na ito.\nUna, dapat malaman na ang lamok na Aedes aegypti ay nabubuhay sa malinis na tubig. Palagi dapat sinusuri ang loob at labas ng bahay kung may mga naipong tubig na hindi napapalitan. Kung minsan ay may mga programa rin ang lokal na gobyerno para mapuksa ang mga lamok katulad ng fogging.\nIginiit ng DOH na sa lahat ng mga paraang ito, mahalaga talaga ang pakikiisa ng bawat mamamayan sa komunidad. Ito ang pinakamabisang paraan upang mapuksa ang sakit na ito.",
        "type": "pretest",
        "gradeLevel": "Grade 6",
        "set": "Set C",
        "quizzes": [
            {
                "question": "Ano ang kondisyon na dala ng ilang uri ng lamok tulad ng Aedes aegypti?",
                "options": ["dengue fever", "hepatitis", "hika", "malaria"],
                "correctAnswer": "dengue fever"
            },
            {
                "question": "Anong ahensya ng gobyerno ang namamahala sa paghanap ng solusyon tungkol sa problema ng dengue?",
                "options": ["Department of Health", "Department of Education", "Department of Science and Technology", "Department of Public Works and Highways"],
                "correctAnswer": "Department of Health"
            },
            {
                "question": "Bakit patuloy ang pagdami ng may sakit na dengue?",
                "options": ["patuloy na nagkakahawaan ang may sakit", "patuloy na walang mainom na tamang gamot", "patuloy na di kumakain nang tama ang mga tao", "patuloy na nabubuhay ang lamok sa maruming paligid"],
                "correctAnswer": "patuloy na nabubuhay ang lamok sa maruming paligid"
            },
            {
                "question": "Ano ang mararamdaman ng babasa ng unang bahagi ng seleksyong ito?",
                "options": ["magagalit", "mananabik", "mangangamba", "matutuwa"],
                "correctAnswer": "mangangamba"
            },
            {
                "question": "Ano ang kasingkahulugan ng sugpuin sa pangungusap sa kahon?\nPatuloy na gumagawa ng paraan ang DOH upang sugpuin ang dengue.",
                "options": ["pigilan", "paalisin", "subukan", "tulungan"],
                "correctAnswer": "pigilan"
            },
            {
                "question": "Ano ang maaaring mangyari kapag hindi nagtulong-tulong ang mga mamamayan sa problemang nakasaad sa seleksyon?",
                "options": ["Magiging marumi ang kapaligiran.", "Patuloy ang pagkakaroon ng dengue.", "Mag-aaway-away ang magkakapitbahay.", "Hindi magagawa ang programang fogging."],
                "correctAnswer": "Patuloy ang pagkakaroon ng dengue."
            },
            {
                "question": "Ano ang katangian ng mga tao sa DOH na patuloy na naghahanap ng paraan upang malutas ang problema sa seleksyon?",
                "options": ["maawain", "magalang", "matiyaga", "mapagbigay"],
                "correctAnswer": "matiyaga"
            },
            {
                "question": "Ano kaya ang layunin ng sumulat ng seleksyong ito?",
                "options": ["maghatid ng impormasyon sa tao", "magbahagi ng ginawang pag-aaral", "magbigay aliw sa mga may dengue", "magbigay ng mabuting halimbawa"],
                "correctAnswer": "maghatid ng impormasyon sa tao"
            }
        ]
    },
    {
        "title": "Pagsalungat ni Macario Sakay",
        "content": "Maraming mga bayani ang namatay sa panahon ng pananakop ng mga Amerikano. Isa rito si Macario Sakay. Isa siya sa orihinal na kasapi ng Katipunan na binuo noong panahon ng pananakop ng mga Espanyol.\nSi Macario Sakay ay salungat sa pakikipagkaibigan sa pamahalaang Amerikano. Nagtatag siya ng pamahalaan sa Katagalugan. Siya at ang kanyang mga kasama ay sumulat ng Saligang Batas na nagtakda ng pamamaraan katulad ng sa unang Republika ng Pilipinas na itinatag ni Aguinaldo sa Malolos. Ipinahayag niya ang pakikipaglaban sa mga Amerikano upang makamit ang kalayaan. Sa loob ng apat na taon ay naging matagumpay ang kanyang kilusan at naging problema siya ng mga Amerikano.\nGinamit ng mga Amerikano, sa pamumuno ni Gobernador-Heneral Henry C. Ide, ang isang kilalang lider ng mga manggagawa upang himuking sumuko si Macario Sakay. Siya si Dominador Gomez, na isang Pilipino. Nahimok ni Gomez si Sakay dahil sa pangakong hindi sila parurusahan at sinabing sa kanyang pagsuko ay manunumbalik ang katahimikan ng bansa at magiging simula ito ng pagtatag ng Asembleya ng Pilipinas. Naniwala si Sakay sa mga sinabi ni Gomez. Naniwala siya na ang kanyang pagsuko ay makapagpapadali sa pagtatag ng asembleya na binubuo ng mga Pilipino.\nNabigla si Sakay nang ang kanyang pangkat ay arestuhin ng mga Amerikano at konstabularyang Pilipino sa isang kasiyahan. Pinaratangan ng maraming kasalanan si Sakay ngunit di siya natinag. Ang tanging hangad niya ay makamit ng bansa ang kalayaan. Hinatulan siya ng kamatayan at binitay noong Setyembre 13, 1907.",
        "type": "pretest",
        "gradeLevel": "Grade 7",
        "set": "Set C",
        "quizzes": [
            {
                "question": "Sino ang ayaw makipagkaibigan sa pamahalaang Amerikano?",
                "options": ["Dominador Gomez", "Emilio Aguinaldo", "Henry Ide", "Macario Sakay"],
                "correctAnswer": "Macario Sakay"
            },
            {
                "question": "Ano ang isinulat ni Macario Sakay at ng kanyang mga kasama?",
                "options": ["artikulo sa pahayagan", "asamblea", "nobela", "Saligang batas"],
                "correctAnswer": "Saligang batas"
            },
            {
                "question": "Bakit ayaw makipagkaibigan ni Macario Sakay sa pamahalaan ng Amerika?",
                "options": ["dahil Pilipino siya", "gusto niyang makipag-away", "gusto niyang makamit ang kalayaan", "ayaw niyang pumunta sa Amerika"],
                "correctAnswer": "ayaw niyang pumunta sa Amerika"
            },
            {
                "question": "Sa linyang “sa kanyang pagsuko ay manunumbalik ang katahimikan,” ang ibig sabihin ng salitang manunumbalik ay",
                "options": ["magkakaroon muli", "maririnig ng lahat", "makukuha agad", "dapat maiipon"],
                "correctAnswer": "magkakaroon muli"
            },
            {
                "question": "Paano mo ilalarawan ang plano na gamitin si Dominador Gomez para pasukuin si Macario Sakay?",
                "options": ["mautak at tuso", "hindi pinag-isipan", "mapagmalaki at mayabang", "mabait at may pakundangan"],
                "correctAnswer": "mautak at tuso"
            },
            {
                "question": "Anong katangian ang ipinakita ni Macario Sakay?",
                "options": ["makabayan", "matalino", "masinop", "masipag"],
                "correctAnswer": "makabayan"
            },
            {
                "question": "Bakit kaya hangad ni Macario Sakay ang kalayaan ng Pilipinas?",
                "options": ["galit siya sa mga Amerikano", "gusto niyang mamuno sa bansa", "mahal niya ang bansang Pilipinas", "maraming makukuhang yaman sa bansa"],
                "correctAnswer": "mahal niya ang bansang Pilipinas"
            },
            {
                "question": "Ang layunin ng talatang ito ay para ipaliwanag",
                "options": ["ang dahilan ng pagkamatay ni Macario Sakay.", "ang hangarin ni Macario Sakay sa pagpunta sa Malolos.", "ang tungkulin ni Macario Sakay sa mga pinunong Amerikano.", "ang papel ni Macario Sakay sa pagtatag ng Republika."],
                "correctAnswer": "ang dahilan ng pagkamatay ni Macario Sakay."
            }
        ]
    },


    {
        "title": "Sako ni Rita",
        "content": "May sako si Rita.\nMalaki ang sako.\nPuti ang sako.\nNasa mesa ang sako ni Rita.\nMay saba ang sako.\nMarami ang saba sa sako.\nMay tali ang sako.\nPula ang tali ng sako.\nAba! May laso pa sa tali ng sako!",
        "type": "pretest",
        "gradeLevel": "Grade 1",
        "set": "Set D",
        "quizzes": [
            {
                "question": "Sino ang may sako?",
                "options": ["Rita", "Rico", "Maya"],
                "correctAnswer": "Rita"
            },
            {
                "question": "Ano ang laman ng sako?",
                "options": ["laso", "tali", "saba"],
                "correctAnswer": "saba"
            },
            {
                "question": "Ano kaya ang gagawin ni Rita?",
                "options": ["mag-iipon ng sako", "magtitinda ng saba", "magpapakain ng baka"],
                "correctAnswer": "magtitinda ng saba"
            },
            {
                "question": "Ano ang damdamin na ipinahahayag sa katapusan ng kuwento?",
                "options": ["gulat", "takot", "lungkot"],
                "correctAnswer": "gulat"
            },
            {
                "question": "Ano pa ang puwedeng gawin sa sako?",
                "options": ["lalagyan ng gamit", "panligo sa hayop", "pagkain ng insekto"],
                "correctAnswer": "lalagyan ng gamit"
            }
        ]
    },
    {
        "title": "Ang Ibon ni Islaw",
        "content": "May alagang ibon si Islaw.\nIsing ang pangalan ng ibon niya.\nPuti si Ising. Maliit si Ising.\nNasa isang hawla si Ising.\nAraw-araw ay binibigyan ng pagkain ni Islaw si Ising.\nMasaya si Islaw sa alaga niya.\nIsang araw, nakawala sa hawla si Ising.\nHinanap ni Islaw si Ising.\nHindi nakita ni Islaw si Ising.\nPag-uwi ni Islaw, naroon na si Ising.\nHinihintay na siya sa loob ng bahay.",
        "type": "pretest",
        "gradeLevel": "Grade 2",
        "set": "Set D",
        "quizzes": [
            {
                "question": "Ano ang alaga ni Islaw?",
                "options": ["tuta", "pusa", "ibon"],
                "correctAnswer": "ibon"
            },
            {
                "question": "Ano ang ginagawa ni Islaw kay Ising araw-araw?",
                "options": ["pinaliliguan", "pinapasyal", "pinakakain"],
                "correctAnswer": "pinakakain"
            },
            {
                "question": "Anong katangian ang ipinakikita ni Islaw?",
                "options": ["maalaga", "masinop", "maunawain"],
                "correctAnswer": "maalaga"
            },
            {
                "question": "Ano ang naramdaman ni Islaw nang mawala si Ising?",
                "options": ["nag-alala", "natuwa", "nagalit"],
                "correctAnswer": "nag-alala"
            },
            {
                "question": "Ano ang ginawa ni Islaw na nagpakita ng kanyang pagiging maalalahanin?",
                "options": ["Hinanap niya si Ising.", "Pinamigay niya ang alaga.", "Pinabayaan niya ang alagang mawala."],
                "correctAnswer": "Hinanap niya si Ising."
            }
        ]
    },
    {
        "title": "Laruang Dyip",
        "content": "Araw na ng Sabado. Kausap ni Romy ang kaibigang si Bert. Gusto nilang maglaro, pero pareho silang walang dalang laruan.\n“Alam ko na! Gumawa tayo ng laruang dyip,” naisip ni Rom.\n“Paano?” tanong ni Bert.\n“Ihanda muna natin ang mga takip ng bote o tansan para sa gulong.\nPagkatapos, kailangan nating maghanap ng kahon ng posporo para sa katawan. Manghingi naman tayo ng kapirasong tela kay Nanay para sa upuan,” paliwanag ni Rom.\n“Paano kaya ito tatakbo, kahit walang baterya?” tanong ni Bert.\n“E, di talian natin at hilahin,” sagot ni Romy.",
        "type": "pretest",
        "gradeLevel": "Grade 3",
        "set": "Set D",
        "quizzes": [
            {
                "question": "Sino ang magkaibigan?",
                "options": ["Romy at Bert", "Remy at Betty", "Ronald at Ben"],
                "correctAnswer": "Romy at Bert"
            },
            {
                "question": "Ano ang gusto nilang buuin?",
                "options": ["laruang kahon", "laruang sasakyan", "laruang telepono"],
                "correctAnswer": "laruang sasakyan"
            },
            {
                "question": "Anong salita sa kuwento ang may ibig sabihin na maliit na bahagi?",
                "options": ["kailangan", "kapiraso", "tansan"],
                "correctAnswer": "kapiraso"
            },
            {
                "question": "Bakit gusto nilang gumawa ng laruan?",
                "options": ["Wala silang laruan.", "Gumaya sila sa kaklase.", "Nainggit sila sa mga kalaro."],
                "correctAnswer": "Wala silang laruan."
            },
            {
                "question": "Ano ang mga ginamit nila upang buuin ang laruan?",
                "options": ["mga lumang laruan", "mga nakita nila sa halamanan", "mga gamit na maaari nang ibasura"],
                "correctAnswer": "mga gamit na maaari nang ibasura"
            },
            {
                "question": "Anong katangian ang ipinakita ni Romy?",
                "options": ["masipag", "malikhain", "maalalahanin"],
                "correctAnswer": "malikhain"
            }
        ]
    },
    {
        "title": "Galing sa Japan",
        "content": "Sabik na sabik na si Jose. Darating na kasi ang Nanay niyang si Aling Malou. Dalawang taon ding nawala si Aling Malou. Galing siya sa Japan.\nSumama si Jose sa Tatay niya sa paliparan. Hiniram nila ang lumang jeep ni Tito Boy para makapunta roon. Susunduin nila si Aling Malou.\nPagdating sa paliparan, naghintay pa sila. Hindi pa kasi dumarating ang eroplanong sinakyan ni Aling Malou. Hindi nagtagal, may narinig na tinig si Jose.\n“Jose! Lito!” malakas na sigaw ni Aling Malou nang makita ang magama.\n“Inay!” sigaw din ni Jose, sabay takbo nang mabilis palapit kay Aling Malou.\n“Marami akong pasalubong sa iyo, anak,” simula ni Aling Malou. “May jacket, bag, damit at laruan.”\n“Salamat, ‘Nay,” sagot ni Jose. “Pero ang mas gusto ko po, nandito ka na! Kasama ka na namin uli!”",
        "type": "pretest",
        "gradeLevel": "Grade 4",
        "set": "Set D",
        "quizzes": [
            {
                "question": "Sino ang darating sa paliparan?",
                "options": ["si Jose", "si Tito Boy", "si Aling Malou"],
                "correctAnswer": "si Aling Malou"
            },
            {
                "question": "Ilang taon sa Japan si Aling Malou?",
                "options": ["dalawa", "lima", "isa"],
                "correctAnswer": "dalawa"
            },
            {
                "question": "Ano kaya ang ginawa ni Aling Malou sa Japan?",
                "options": ["nagbakasyon", "nagtrabaho", "namasyal"],
                "correctAnswer": "nagtrabaho"
            },
            {
                "question": "Ano kaya ang naramdaman ni Jose habang naghihintay sa pagdating ng nanay niya?",
                "options": ["nasasabik", "naiinip", "naiinis"],
                "correctAnswer": "nasasabik"
            },
            {
                "question": "Bakit kaya maraming pasalubong si Aling Malou kay Jose?",
                "options": ["gusto niyang iparamdam ang kanyang pagmamahal", "gusto niyang gastusin at gamitin ang kanyang pera", "hindi niya gusto ang mga gamit dito sa Pilipinas"],
                "correctAnswer": "gusto niyang iparamdam ang kanyang pagmamahal"
            },
            {
                "question": "Ano ang kahulugan ng sinabi ni Jose na “Salamat, ‘Nay. Pero ang mas gusto ko po, nandito ka na! Kasama ka na namin uli!”",
                "options": ["ayaw niya ng mga binigay na pasalubong", "di niya kailangan ng mga laruan, damit at bag", "higit na mahalaga si Nanay kaysa pasalubong"],
                "correctAnswer": "higit na mahalaga si Nanay kaysa pasalubong"
            }
        ]
    },
    {
        "title": "Ama ng Wikang Pambansa",
        "content": "Si Manuel Quezon ay isang masigla at masipag na lider. Anumang gawaing ninanais niya ay isinasakatuparan niya agad. Ayaw niya na may masayang na panahon dahil naniniwala siya na ang oras ay ginto. Mahalaga ang bawat sandali kaya’t hindi niya ito inaaksaya. Ayon sa kanya, ang magagawa ngayon ay hindi na dapat ipagpabukas pa.\nNaging kawal siya noong panahon ng himagsikan. Naging gobernador din siya, at matapos nito ay naging senador. Naging kinatawan pa siya ng Pilipinas sa Washington, United States of America. Si Quezon ay mahusay sa batas dahil siya ay isang abogado. Di nagtagal, siya ay naging pangulo ng Senado ng Pilipinas at nahalal na pangulo ng Komonwelt o ng Malasariling Pamahalaan noon.\nSa pamamagitan ng pagsasakatuparan ng Katarungang Panlipunan, binigyan niya ng pantay na pagpapahalaga ang mahihirap at mayayaman. Si Quezon din ang nagpasimula sa pagkakaroon natin ng pambansang wika. Kung hindi dahil sa kanya, walang isang wika na magbubuklod sa lahat ng Pilipino. Dahil dito, siya ay tinawag na “Ama ng Wikang Pambansa.”",
        "type": "pretest",
        "gradeLevel": "Grade 5",
        "set": "Set D",
        "quizzes": [
            {
                "question": "Sino ang Ama ng Wikang Pambansa?",
                "options": ["Andres Bonifacio", "Diosdado Macapagal", "Jose Rizal", "Manuel Quezon"],
                "correctAnswer": "Manuel Quezon"
            },
            {
                "question": "Bakit siya tinawag na Ama ng Wikang Pambansa?",
                "options": ["Tinuruan niyang magsalita ng Filipino ang mga tao.", "Kilala siya sa pagiging magaling magsalita ng Filipino.", "Sinimulan niya ang pagkakaroon ng pambansang wika.", "Hinatak niya ang mga Filipino na isa lamang ang gamiting wika."],
                "correctAnswer": "Sinimulan niya ang pagkakaroon ng pambansang wika."
            },
            {
                "question": "Alin sa sumusunod ang mga naging trabaho ni Quezon?",
                "options": ["guro, doktor, abogado", "senador, modelo, kawal", "alkalde, kongresista, pangulo", "abogado, gobernador, senador"],
                "correctAnswer": "abogado, gobernador, senador"
            },
            {
                "question": "Bakit kaya niya sinabing ang magagawa ngayon ay hindi na dapat ipagpabukas pa?",
                "options": ["Madili siyang mainip, kaya dapat tapusin agad ang gawain.", "Pinapahalagahan niya ang oras, kaya hindi ito dapat sayangin.", "Marami siyang ginagawa, kaya kailangang sundin ang iskedyul.", "Lagi siyang nagmamadali, kaya hindi dapat nahuhuli sa gawain."],
                "correctAnswer": "Pinapahalagahan niya ang oras, kaya hindi ito dapat sayangin."
            },
            {
                "question": "Alin sa sumusunod ang nagpapakita na makamahirap si Quezon?",
                "options": ["Tumira siya sa bahay ng mahihirap.", "Binibigyan niya ng pera ang mahihirap.", "Pinatupad niya ang Katarungang Panlipunan.", "Iba ang tingin niya sa mahihirap at mayayaman."],
                "correctAnswer": "Pinatupad niya ang Katarungang Panlipunan."
            },
            {
                "question": "Sa pangungusap na “Naging kawal siya noong panahon ng himagsikan,” ano ang iba pang kahulugan ng salitang kawal?",
                "options": ["bayani", "doktor", "manunulat", "sundalo"],
                "correctAnswer": "sundalo"
            },
            {
                "question": "Anong uri ng seleksyon ang binasa mo?",
                "options": ["alamat", "kuwentong-bayan", "pabula", "talambuhay"],
                "correctAnswer": "talambuhay"
            }
        ]
    },
    {
        "title": "Puno pa rin ng Buhay",
        "content": "Sa kapaligiran ng bansang Pilipinas, marami ang makikitang punong niyog. Kahit saang panig ng bansa, may mga produktong ibinebenta na galing sa puno ng niyog.\nAng niyog ay tinaguriang puno ng buhay. Ang mga bahagi nito mula ugat hanggang dahon ay napakikinabangan. Ang laman ng niyog ay ginagawang buko salad, buko pie at minatamis. Ginagamit din ito bilang sangkap sa paggawa ng arina, mantikilya, sabon, krudong langis, at iba pa. Natuklasan ni Dr. Eufemio Macalalag, Jr., isang urologist na ang paginom ng sabaw ng buko araw-araw ay nakatutulong sa kidney ng isang tao.\nNadiskubre rin niya na nakatutulong ang araw-araw na pag-inom nito para maiwasan ang pagkabuo ng bato sa daanan ng ihi (urinary tract). Ginagamit din itong pamalit ng dextrose.\nNatuklasan pa na mas maraming protina ang nakukuha sa gata ng niyog kaysa sa gatas ng baka. May 2.08 porsiyento ng protina ang gata samantalang 1.63 porsiyento lamang ang sa gatas ng baka. Ang langis ng niyog ay nagagamit din bilang preservative, lubricant, pamahid sa anit, at iba pa.\nAng bulaklak ng niyog ay ginagawang suka at alak. Ang ubod naman ay ginagawang atsara, sariwang lumpiya, at panghalo sa mga lutuing karne o lamang dagat. Pati ang ugat nito ay ginagamit pang panlunas sa iba’t ibang karamdaman.",
        "type": "pretest",
        "gradeLevel": "Grade 6",
        "set": "Set D",
        "quizzes": [
            {
                "question": "Ano ang tinaguriang puno ng buhay?",
                "options": ["puno ng buko", "puno ng narra", "puno ng niyog", "puno ng mangga"],
                "correctAnswer": "puno ng niyog"
            },
            {
                "question": "Alin sa sumusunod ang HINDI maaaring gawin sa laman ng niyog?",
                "options": ["kendi", "buko pie", "dextrose", "minatamis"],
                "correctAnswer": "dextrose"
            },
            {
                "question": "Ilang porsiyento ng protina ang makukuha sa gata ng niyog?",
                "options": ["1.63", "2.08", "2.9", "3.0"],
                "correctAnswer": "2.08"
            },
            {
                "question": "Sa anong bahagi ng katawan nakabubuti ang pag-inom ng sabaw ng buko/niyog?",
                "options": ["atay", "baga", "kidney", "puso"],
                "correctAnswer": "kidney"
            },
            {
                "question": "Bakit mas mainam ang gata ng niyog kaysa gatas ng baka?",
                "options": ["Mas masarap ito.", "Mas mura ang niyog kaysa gatas.", "Mas maraming pagkukuhanan ng niyog.", "Mas maraming protina ang nakukuha rito."],
                "correctAnswer": "Mas maraming protina ang nakukuha rito."
            },
            {
                "question": "Bakit tinaguriang puno ng buhay ang puno ng niyog?",
                "options": ["Hanapbuhay ng maraming tao ang pagtatanim ng niyog.", "Maraming nagbebenta ng produkto ng niyog.", "Marami ang pakinabang sa niyog.", "Marami ang niyog sa Pilipinas."],
                "correctAnswer": "Marami ang pakinabang sa niyog."
            },
            {
                "question": "Ano ang tinitingnan ng isang urologist?",
                "options": ["ugat ng tao", "dugo at atay", "puso at dugo", "urinary tract"],
                "correctAnswer": "urinary tract"
            },
            {
                "question": "Ano ang layunin ng sumulat ng seleksyong ito?",
                "options": ["Nais nitong hikayatin ang tao na magtanim ng puno ng niyog.", "Gusto nitong ipaalam ang iba't ibang gamit ng niyog.", "Hangad nitong magbenta tayo ng produkto ng niyog.", "Nais nitong magbigay ng ikabubuhay ng tao."],
                "correctAnswer": "Gusto nitong ipaalam ang iba't ibang gamit ng niyog."
            }
        ]
    },
    {
        "title": "Talambuhay ni Benigno Aquino Jr.",
        "content": "Si Benigno Aquino Jr. o kilalang si Ninoy Aquino ay ipinanganak noong Nobyembre 27, 1932 sa Concepcion, Tarlac. Kumuha siya ng Law sa Unibersidad ng Pilipinas ngunit tumigil siya at sa halip ay kumuha siya ng Journalism. Pinakasalan niya si Corazon Aquino at nagkaroon sila ng limang anak.\nSiya ay naging alkalde ng Concepcion, Tarlac at pinakabatang bisegobernador ng Tarlac. Sa edad na 34, nahalal siya bilang senador.\nSiya ay naging mahigpit na kritiko ni Pangulong Marcos at ng asawa nitong si Imelda Marcos. Kilala siyang kalaban ni Pangulong Marcos tuwing halalan. Nang ideklara ang Martial Law, si Benigno Aquino ang isa sa mga unang dinampot ng militar upang ikulong.\nNoong 1980, siya ay inatake sa puso at kinailangang operahan.\nPinayagan siya ni Imelda Marcos na lumabas ng bansa para magpagamot sa kundisyong siya ay babalik at hindi magsasalita laban sa pamahalaan ni Marcos. Si Aquino ay namalagi sa Estados Unidos ng tatlong taon.\nDahil sa balitang lumalalang sakit ni Pangulong Marcos, ipinasya ni Aquino na umuwi upang bigyan ng pag-asa ang mga taong naghahangad ng pagbabago sa pamahalaan.\nNoong Agosto 21, 1983, bumalik siya sa Maynila subalit sa paliparan pa lang ay binaril siya sa ulo. Ang libing ni Ninoy Aquino ay nagsimula ng ika-9 ng umaga hanggang ika-9 ng gabi. Mahigit dalawang milyong tao ang nag-abang sa pagdaan ng karosa ng kabaong ni Ninoy papunta sa Manila Memorial Park.",
        "type": "pretest",
        "gradeLevel": "Grade 7",
        "set": "Set D",
        "quizzes": [
            {
                "question": "Saan ipinanganak si Ninoy Aquino?",
                "options": ["Tarlac, Tarlac", "Capas, Tarlac", "Camiling, Tarlac", "Concepcion, Tarlac"],
                "correctAnswer": "Concepcion, Tarlac"
            },
            {
                "question": "Alin sa sumusunod ang naging posisyon sa pamahalaan ni Ninoy Aquino?",
                "options": ["presidente, bise-presidente, senador", "konsehal, kongresista, gobernador", "alkalde, bise-gobernador, senador", "bise-alkalde, konsehal, pangulo"],
                "correctAnswer": "alkalde, bise-gobernador, senador"
            },
            {
                "question": "Sinabi sa talata na si Ninoy Aquino ang mahigpit na kritiko ni Pangulong Marcos. Ano ang ginagawa ng isang kritiko?",
                "options": ["nakikipag-away", "nag-iisip ng paghiganti", "nagsasabi ng mga puna", "nagpaplano ng ganti"],
                "correctAnswer": "nagsasabi ng mga puna"
            },
            {
                "question": "Kung pangulo ng Pilipinas ang maaaring magpahayag ng martial law, sino kaya ang nagdeklara nito noong panahong iyon?",
                "options": ["Cory Aquino", "Fidel Ramos", "Imelda Marcos", "Ferdinand Marcos"],
                "correctAnswer": "Ferdinand Marcos"
            },
            {
                "question": "Bakit kaya ipinadampot si Ninoy Aquino noong martial law?",
                "options": ["May inaway na alkalde si Ninoy Aquino.", "May galit si Marcos sa pamilya ni Aquino.", "Nahuli si Aquino na nagnanakaw sa pamahalaan.", "Bawal kalabanin ang pangulo noong martial law."],
                "correctAnswer": "Bawal kalabanin ang pangulo noong martial law."
            },
            {
                "question": "Ano ang katangiang ipinakita ni Ninoy Aquino?",
                "options": ["maalalahanin", "magalang", "makabayan", "mapagtiis"],
                "correctAnswer": "makabayan"
            },
            {
                "question": "Bakit kaya marami ang nakiramay sa kamatayan ni Ninoy Aquino?",
                "options": ["Isa siyang batang senador.", "Naawa sila sa pamilya ni Aquino.", "Pagmamahal sa bayan ang ipinakita niya.", "Gusto ng mga taong makakita ng mga pulitiko."],
                "correctAnswer": "Pagmamahal sa bayan ang ipinakita niya."
            },
            {
                "question": "Ano ang damdamin na iniwan ni Ninoy Aquino sa mga Pilipino?",
                "options": ["kasabikan", "pag-asa", "pagkatalo", "pagkatakot"],
                "correctAnswer": "pag-asa"
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