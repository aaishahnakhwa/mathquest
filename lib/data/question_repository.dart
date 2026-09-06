import 'dart:math';
import '../models/question_model.dart';

class QuestionRepository {
  // ==========================================
  // WORLD 1: SINGLE-DIGIT ARITHMETIC
  // ==========================================

  // World 1 - Level 1: Single-Digit Addition
  static const List<QuestionModel> world1Level1Questions = [
    QuestionModel(
      id: 'w1_l1_q1',
      topic: 'Addition',
      difficulty: 'Beginner',
      questionText: 'What is 4 + 5?',
      options: ['8', '9', '10', '7'],
      correctAnswerIndex: 1,
      explanationSteps: [
        'Start at 4 on the number line.',
        'Count forward 5 steps: 5, 6, 7, 8, 9.',
        'Therefore, 4 + 5 = 9!'
      ],
      hintText: 'Count 5 up from 4.',
      xpReward: 15,
      coinReward: 8,
      gemReward: 1,
    ),
    QuestionModel(
      id: 'w1_l1_q2',
      topic: 'Addition',
      difficulty: 'Beginner',
      questionText: 'Calculate: 7 + 8',
      options: ['14', '16', '15', '13'],
      correctAnswerIndex: 2,
      explanationSteps: [
        'Think of 8 as 3 + 5:',
        '7 + 3 = 10',
        '10 + 5 = 15',
        'Therefore, 7 + 8 = 15!'
      ],
      hintText: 'Add 3 to 7 to make 10, then add 5 more.',
      xpReward: 15,
      coinReward: 8,
      gemReward: 1,
    ),
    QuestionModel(
      id: 'w1_l1_q3',
      topic: 'Addition',
      difficulty: 'Beginner',
      questionText: 'What is 9 + 6?',
      options: ['15', '14', '16', '17'],
      correctAnswerIndex: 0,
      explanationSteps: [
        'Take 1 from 6 and give it to 9 to make 10.',
        'Now you have 10 + 5 = 15.',
        'Therefore, 9 + 6 = 15!'
      ],
      hintText: '9 + 1 = 10, then add the remaining 5.',
      xpReward: 15,
      coinReward: 8,
      gemReward: 1,
    ),
    QuestionModel(
      id: 'w1_l1_q4',
      topic: 'Addition',
      difficulty: 'Beginner',
      questionText: 'Solve: 6 + 7',
      options: ['12', '13', '14', '15'],
      correctAnswerIndex: 1,
      explanationSteps: [
        'Double 6 is 12.',
        'Since 7 is 6 + 1, add 1 to 12: 12 + 1 = 13.',
        'Therefore, 6 + 7 = 13!'
      ],
      hintText: 'Double 6 is 12, then add 1 more.',
      xpReward: 20,
      coinReward: 10,
      gemReward: 1,
    ),
    QuestionModel(
      id: 'w1_l1_q5',
      topic: 'Addition',
      difficulty: 'Beginner',
      questionText: 'What is 8 + 9?',
      options: ['16', '18', '17', '19'],
      correctAnswerIndex: 2,
      explanationSteps: [
        'Think of 9 as 10 - 1.',
        '8 + 10 = 18',
        '18 - 1 = 17',
        'Therefore, 8 + 9 = 17!'
      ],
      hintText: '8 + 10 = 18. Subtract 1 to get the answer.',
      xpReward: 20,
      coinReward: 10,
      gemReward: 1,
    ),
  ];

  // World 1 - Level 2: Single-Digit Subtraction
  static const List<QuestionModel> world1Level2Questions = [
    QuestionModel(
      id: 'w1_l2_q1',
      topic: 'Subtraction',
      difficulty: 'Beginner',
      questionText: 'What is 9 - 4?',
      options: ['6', '5', '4', '3'],
      correctAnswerIndex: 1,
      explanationSteps: [
        'Start at 9 on the number line.',
        'Count backward 4 steps: 8, 7, 6, 5.',
        'Therefore, 9 - 4 = 5!'
      ],
      hintText: 'Count 4 steps down from 9.',
      xpReward: 15,
      coinReward: 8,
      gemReward: 1,
    ),
    QuestionModel(
      id: 'w1_l2_q2',
      topic: 'Subtraction',
      difficulty: 'Beginner',
      questionText: 'Calculate: 8 - 3',
      options: ['5', '6', '4', '7'],
      correctAnswerIndex: 0,
      explanationSteps: [
        '8 - 3 means taking 3 away from 8.',
        '8 - 3 = 5',
        'Check: 5 + 3 = 8!'
      ],
      hintText: 'What number added to 3 equals 8?',
      xpReward: 15,
      coinReward: 8,
      gemReward: 1,
    ),
    QuestionModel(
      id: 'w1_l2_q3',
      topic: 'Subtraction',
      difficulty: 'Beginner',
      questionText: 'What is 14 - 6?',
      options: ['7', '9', '8', '6'],
      correctAnswerIndex: 2,
      explanationSteps: [
        'Subtract 4 to get to 10: 14 - 4 = 10.',
        'Subtract the remaining 2: 10 - 2 = 8.',
        'Therefore, 14 - 6 = 8!'
      ],
      hintText: '14 - 4 = 10, then take away 2 more.',
      xpReward: 20,
      coinReward: 10,
      gemReward: 1,
    ),
    QuestionModel(
      id: 'w1_l2_q4',
      topic: 'Subtraction',
      difficulty: 'Beginner',
      questionText: 'Solve: 15 - 8',
      options: ['6', '7', '8', '9'],
      correctAnswerIndex: 1,
      explanationSteps: [
        '15 - 5 = 10.',
        '10 - 3 = 7.',
        'Therefore, 15 - 8 = 7!'
      ],
      hintText: 'Subtract 5 to get 10, then take away 3 more.',
      xpReward: 20,
      coinReward: 10,
      gemReward: 1,
    ),
    QuestionModel(
      id: 'w1_l2_q5',
      topic: 'Subtraction',
      difficulty: 'Beginner',
      questionText: 'What is 17 - 9?',
      options: ['7', '9', '8', '10'],
      correctAnswerIndex: 2,
      explanationSteps: [
        '9 is 10 - 1.',
        '17 - 10 = 7.',
        'Add 1 back: 7 + 1 = 8.',
        'Therefore, 17 - 9 = 8!'
      ],
      hintText: '17 - 10 = 7. Add 1 back.',
      xpReward: 20,
      coinReward: 10,
      gemReward: 1,
    ),
  ];

  // World 1 - Level 3: Single-Digit Multiplication
  static const List<QuestionModel> world1Level3Questions = [
    QuestionModel(
      id: 'w1_l3_q1',
      topic: 'Multiplication',
      difficulty: 'Beginner',
      questionText: 'What is 3 × 4?',
      options: ['10', '12', '14', '16'],
      correctAnswerIndex: 1,
      explanationSteps: [
        '3 × 4 means 3 groups of 4 (or 4 + 4 + 4).',
        '4 + 4 = 8',
        '8 + 4 = 12',
        'Therefore, 3 × 4 = 12!'
      ],
      hintText: 'Add 4 three times: 4 + 4 + 4.',
      xpReward: 20,
      coinReward: 10,
      gemReward: 1,
    ),
    QuestionModel(
      id: 'w1_l3_q2',
      topic: 'Multiplication',
      difficulty: 'Beginner',
      questionText: 'Calculate: 6 × 7',
      options: ['42', '36', '48', '40'],
      correctAnswerIndex: 0,
      explanationSteps: [
        '6 × 6 = 36.',
        'Add one more group of 6: 36 + 6 = 42.',
        'Therefore, 6 × 7 = 42!'
      ],
      hintText: '6 × 6 = 36. Add 6 more.',
      xpReward: 20,
      coinReward: 10,
      gemReward: 1,
    ),
    QuestionModel(
      id: 'w1_l3_q3',
      topic: 'Multiplication',
      difficulty: 'Beginner',
      questionText: 'What is 8 × 9?',
      options: ['64', '72', '81', '70'],
      correctAnswerIndex: 1,
      explanationSteps: [
        'Use the 9s trick: 8 × 10 = 80.',
        'Subtract 8: 80 - 8 = 72.',
        'Therefore, 8 × 9 = 72!'
      ],
      hintText: '8 × 10 = 80. Subtract 8.',
      xpReward: 25,
      coinReward: 12,
      gemReward: 1,
    ),
    QuestionModel(
      id: 'w1_l3_q4',
      topic: 'Multiplication',
      difficulty: 'Beginner',
      questionText: 'Solve: 5 × 6',
      options: ['25', '30', '35', '20'],
      correctAnswerIndex: 1,
      explanationSteps: [
        'Counting by 5s: 5, 10, 15, 20, 25, 30.',
        'Therefore, 5 × 6 = 30!'
      ],
      hintText: 'Count by 5s six times.',
      xpReward: 25,
      coinReward: 12,
      gemReward: 1,
    ),
    QuestionModel(
      id: 'w1_l3_q5',
      topic: 'Multiplication',
      difficulty: 'Beginner',
      questionText: 'What is 9 × 4?',
      options: ['32', '38', '36', '34'],
      correctAnswerIndex: 2,
      explanationSteps: [
        'Double and double trick:',
        '9 × 2 = 18',
        '18 × 2 = 36',
        'Therefore, 9 × 4 = 36!'
      ],
      hintText: 'Double 9 twice: 9 → 18 → 36.',
      xpReward: 25,
      coinReward: 12,
      gemReward: 1,
    ),
  ];

  // World 1 - Level 4: Single-Digit Division
  static const List<QuestionModel> world1Level4Questions = [
    QuestionModel(
      id: 'w1_l4_q1',
      topic: 'Division',
      difficulty: 'Beginner',
      questionText: 'What is 8 ÷ 2?',
      options: ['3', '4', '5', '6'],
      correctAnswerIndex: 1,
      explanationSteps: [
        'Split 8 into 2 equal parts.',
        'What number times 2 equals 8? 4 × 2 = 8.',
        'Therefore, 8 ÷ 2 = 4!'
      ],
      hintText: 'Cut 8 in half.',
      xpReward: 20,
      coinReward: 10,
      gemReward: 1,
    ),
    QuestionModel(
      id: 'w1_l4_q2',
      topic: 'Division',
      difficulty: 'Beginner',
      questionText: 'Calculate: 9 ÷ 3',
      options: ['2', '3', '4', '5'],
      correctAnswerIndex: 1,
      explanationSteps: [
        '9 divided into 3 equal groups.',
        '3 × 3 = 9.',
        'Therefore, 9 ÷ 3 = 3!'
      ],
      hintText: 'What number multiplied by 3 gives 9?',
      xpReward: 20,
      coinReward: 10,
      gemReward: 1,
    ),
    QuestionModel(
      id: 'w1_l4_q3',
      topic: 'Division',
      difficulty: 'Beginner',
      questionText: 'What is 12 ÷ 4?',
      options: ['2', '3', '4', '6'],
      correctAnswerIndex: 1,
      explanationSteps: [
        '12 ÷ 4 is asking how many 4s make 12.',
        '4 + 4 + 4 = 12 (3 times).',
        'Therefore, 12 ÷ 4 = 3!'
      ],
      hintText: 'Count by 4s up to 12.',
      xpReward: 25,
      coinReward: 12,
      gemReward: 1,
    ),
    QuestionModel(
      id: 'w1_l4_q4',
      topic: 'Division',
      difficulty: 'Beginner',
      questionText: 'Solve: 18 ÷ 6',
      options: ['2', '3', '4', '5'],
      correctAnswerIndex: 1,
      explanationSteps: [
        '6 × ? = 18',
        '6 × 3 = 18',
        'Therefore, 18 ÷ 6 = 3!'
      ],
      hintText: '6 times what equals 18?',
      xpReward: 25,
      coinReward: 12,
      gemReward: 1,
    ),
    QuestionModel(
      id: 'w1_l4_q5',
      topic: 'Division',
      difficulty: 'Beginner',
      questionText: 'What is 24 ÷ 8?',
      options: ['2', '3', '4', '6'],
      correctAnswerIndex: 1,
      explanationSteps: [
        '8 × 3 = 24',
        'Therefore, 24 ÷ 8 = 3!'
      ],
      hintText: '8 times what equals 24?',
      xpReward: 25,
      coinReward: 12,
      gemReward: 1,
    ),
  ];

  // World 1 - Level 5: All Math Operations Challenge (Grand Boss Level)
  static const List<QuestionModel> world1Level5Questions = [
    QuestionModel(
      id: 'w1_l5_q1',
      topic: 'Addition',
      difficulty: 'Intermediate',
      questionText: 'What is 8 + 7?',
      options: ['13', '14', '15', '16'],
      correctAnswerIndex: 2,
      explanationSteps: [
        'Start with 8.',
        'Add 7 more: 8 + 7 = 15.',
        'Therefore, 8 + 7 = 15!'
      ],
      hintText: '8 + 2 = 10, then add 5 more.',
      xpReward: 35,
      coinReward: 15,
      gemReward: 2,
    ),
    QuestionModel(
      id: 'w1_l5_q2',
      topic: 'Subtraction',
      difficulty: 'Intermediate',
      questionText: 'Calculate: 16 - 9',
      options: ['6', '7', '8', '9'],
      correctAnswerIndex: 1,
      explanationSteps: [
        '16 - 10 = 6.',
        'Since we subtract 9 (one less than 10), add 1 back: 6 + 1 = 7.',
        'Therefore, 16 - 9 = 7!'
      ],
      hintText: '16 - 10 = 6, then add 1 back.',
      xpReward: 35,
      coinReward: 15,
      gemReward: 2,
    ),
    QuestionModel(
      id: 'w1_l5_q3',
      topic: 'Multiplication',
      difficulty: 'Intermediate',
      questionText: 'What is 7 × 6?',
      options: ['36', '40', '42', '48'],
      correctAnswerIndex: 2,
      explanationSteps: [
        '7 × 5 = 35.',
        'Add one more group of 7: 35 + 7 = 42.',
        'Therefore, 7 × 6 = 42!'
      ],
      hintText: '7 times 5 is 35. Add 7 more.',
      xpReward: 35,
      coinReward: 15,
      gemReward: 2,
    ),
    QuestionModel(
      id: 'w1_l5_q4',
      topic: 'Division',
      difficulty: 'Intermediate',
      questionText: 'Solve: 35 ÷ 5',
      options: ['5', '6', '7', '8'],
      correctAnswerIndex: 2,
      explanationSteps: [
        'How many 5s equal 35?',
        '5 × 7 = 35.',
        'Therefore, 35 ÷ 5 = 7!'
      ],
      hintText: 'Count by 5s up to 35.',
      xpReward: 40,
      coinReward: 20,
      gemReward: 2,
    ),
    QuestionModel(
      id: 'w1_l5_q5',
      topic: 'Mixed Operations',
      difficulty: 'Mastery',
      questionText: 'What is 9 + 6 - 4?',
      options: ['10', '11', '12', '13'],
      correctAnswerIndex: 1,
      explanationSteps: [
        'First add: 9 + 6 = 15.',
        'Then subtract 4: 15 - 4 = 11.',
        'Therefore, 9 + 6 - 4 = 11!'
      ],
      hintText: 'Add 9 + 6 first (15), then take away 4.',
      xpReward: 45,
      coinReward: 25,
      gemReward: 3,
    ),
  ];

  // ==========================================
  // WORLD 2: TWO-DIGIT ARITHMETIC
  // ==========================================

  // World 2 - Level 1: Two-Digit Addition
  static const List<QuestionModel> world2Level1Questions = [
    QuestionModel(
      id: 'w2_l1_q1',
      topic: 'Addition',
      difficulty: 'Intermediate',
      questionText: 'What is 24 + 35?',
      options: ['57', '59', '61', '55'],
      correctAnswerIndex: 1,
      explanationSteps: [
        'Add tens: 20 + 30 = 50',
        'Add ones: 4 + 5 = 9',
        'Combine: 50 + 9 = 59',
        'Therefore, 24 + 35 = 59!'
      ],
      hintText: '20 + 30 = 50, and 4 + 5 = 9.',
      xpReward: 25,
      coinReward: 10,
      gemReward: 1,
    ),
    QuestionModel(
      id: 'w2_l1_q2',
      topic: 'Addition',
      difficulty: 'Intermediate',
      questionText: 'Calculate: 48 + 37',
      options: ['83', '85', '87', '75'],
      correctAnswerIndex: 1,
      explanationSteps: [
        '40 + 30 = 70',
        '8 + 7 = 15',
        '70 + 15 = 85',
        'Therefore, 48 + 37 = 85!'
      ],
      hintText: '48 + 30 = 78. Add 7 more.',
      xpReward: 25,
      coinReward: 10,
      gemReward: 1,
    ),
    QuestionModel(
      id: 'w2_l1_q3',
      topic: 'Addition',
      difficulty: 'Intermediate',
      questionText: 'What is 63 + 29?',
      options: ['90', '92', '94', '82'],
      correctAnswerIndex: 1,
      explanationSteps: [
        'Think of 29 as 30 - 1:',
        '63 + 30 = 93',
        '93 - 1 = 92',
        'Therefore, 63 + 29 = 92!'
      ],
      hintText: 'Add 30 to 63 (93), then subtract 1.',
      xpReward: 30,
      coinReward: 12,
      gemReward: 1,
    ),
    QuestionModel(
      id: 'w2_l1_q4',
      topic: 'Addition',
      difficulty: 'Intermediate',
      questionText: 'Solve: 56 + 44?',
      options: ['90', '100', '110', '98'],
      correctAnswerIndex: 1,
      explanationSteps: [
        '50 + 40 = 90',
        '6 + 4 = 10',
        '90 + 10 = 100',
        'Therefore, 56 + 44 = 100!'
      ],
      hintText: '56 + 4 = 60. Now add 40 more.',
      xpReward: 30,
      coinReward: 12,
      gemReward: 1,
    ),
    QuestionModel(
      id: 'w2_l1_q5',
      topic: 'Addition',
      difficulty: 'Intermediate',
      questionText: 'What is 78 + 56?',
      options: ['132', '134', '136', '124'],
      correctAnswerIndex: 1,
      explanationSteps: [
        '70 + 50 = 120',
        '8 + 6 = 14',
        '120 + 14 = 134',
        'Therefore, 78 + 56 = 134!'
      ],
      hintText: '78 + 50 = 128. Add 6 more.',
      xpReward: 35,
      coinReward: 15,
      gemReward: 1,
    ),
  ];

  // World 2 - Level 2: Two-Digit Subtraction
  static const List<QuestionModel> world2Level2Questions = [
    QuestionModel(
      id: 'w2_l2_q1',
      topic: 'Subtraction',
      difficulty: 'Intermediate',
      questionText: 'What is 75 - 28?',
      options: ['45', '47', '49', '57'],
      correctAnswerIndex: 1,
      explanationSteps: [
        'Subtract tens: 75 - 20 = 55',
        'Subtract ones: 55 - 8 = 47',
        'Therefore, 75 - 28 = 47!'
      ],
      hintText: '75 - 20 = 55. Take away 8 more.',
      xpReward: 25,
      coinReward: 10,
      gemReward: 1,
    ),
    QuestionModel(
      id: 'w2_l2_q2',
      topic: 'Subtraction',
      difficulty: 'Intermediate',
      questionText: 'Calculate: 84 - 39',
      options: ['43', '45', '47', '55'],
      correctAnswerIndex: 1,
      explanationSteps: [
        '39 is almost 40.',
        '84 - 40 = 44',
        'Add 1 back: 44 + 1 = 45',
        'Therefore, 84 - 39 = 45!'
      ],
      hintText: 'Subtract 40 from 84, then add 1.',
      xpReward: 25,
      coinReward: 10,
      gemReward: 1,
    ),
    QuestionModel(
      id: 'w2_l2_q3',
      topic: 'Subtraction',
      difficulty: 'Intermediate',
      questionText: 'What is 92 - 46?',
      options: ['44', '46', '48', '56'],
      correctAnswerIndex: 1,
      explanationSteps: [
        '92 - 40 = 52',
        '52 - 6 = 46',
        'Therefore, 92 - 46 = 46!'
      ],
      hintText: '92 - 40 = 52. Take away 6 more.',
      xpReward: 30,
      coinReward: 12,
      gemReward: 1,
    ),
    QuestionModel(
      id: 'w2_l2_q4',
      topic: 'Subtraction',
      difficulty: 'Intermediate',
      questionText: 'Solve: 110 - 55',
      options: ['45', '55', '65', '50'],
      correctAnswerIndex: 1,
      explanationSteps: [
        '55 is half of 110.',
        '110 - 55 = 55',
        'Therefore, 110 - 55 = 55!'
      ],
      hintText: 'Double 55 is 110.',
      xpReward: 30,
      coinReward: 12,
      gemReward: 1,
    ),
    QuestionModel(
      id: 'w2_l2_q5',
      topic: 'Subtraction',
      difficulty: 'Intermediate',
      questionText: 'What is 143 - 67?',
      options: ['74', '76', '78', '86'],
      correctAnswerIndex: 1,
      explanationSteps: [
        '143 - 60 = 83',
        '83 - 7 = 76',
        'Therefore, 143 - 67 = 76!'
      ],
      hintText: 'Subtract 60 to get 83, then subtract 7.',
      xpReward: 35,
      coinReward: 15,
      gemReward: 1,
    ),
  ];

  // World 2 - Level 3: Two-Digit Multiplication
  static const List<QuestionModel> world2Level3Questions = [
    QuestionModel(
      id: 'w2_l3_q1',
      topic: 'Multiplication',
      difficulty: 'Intermediate',
      questionText: 'What is 14 × 5?',
      options: ['60', '70', '75', '65'],
      correctAnswerIndex: 1,
      explanationSteps: [
        'Split 14 into 10 + 4:',
        '10 × 5 = 50',
        '4 × 5 = 20',
        '50 + 20 = 70',
        'Therefore, 14 × 5 = 70!'
      ],
      hintText: '10 × 5 = 50, plus 4 × 5 = 20.',
      xpReward: 30,
      coinReward: 12,
      gemReward: 1,
    ),
    QuestionModel(
      id: 'w2_l3_q2',
      topic: 'Multiplication',
      difficulty: 'Intermediate',
      questionText: 'Calculate: 23 × 4',
      options: ['88', '92', '96', '84'],
      correctAnswerIndex: 1,
      explanationSteps: [
        '20 × 4 = 80',
        '3 × 4 = 12',
        '80 + 12 = 92',
        'Therefore, 23 × 4 = 92!'
      ],
      hintText: '20 × 4 = 80. Add 3 × 4 = 12.',
      xpReward: 30,
      coinReward: 12,
      gemReward: 1,
    ),
    QuestionModel(
      id: 'w2_l3_q3',
      topic: 'Multiplication',
      difficulty: 'Intermediate',
      questionText: 'What is 18 × 6?',
      options: ['102', '108', '114', '98'],
      correctAnswerIndex: 1,
      explanationSteps: [
        '10 × 6 = 60',
        '8 × 6 = 48',
        '60 + 48 = 108',
        'Therefore, 18 × 6 = 108!'
      ],
      hintText: '10 × 6 = 60. 8 × 6 = 48. Add them together.',
      xpReward: 35,
      coinReward: 15,
      gemReward: 1,
    ),
    QuestionModel(
      id: 'w2_l3_q4',
      topic: 'Multiplication',
      difficulty: 'Intermediate',
      questionText: 'Solve: 25 × 6',
      options: ['125', '150', '175', '140'],
      correctAnswerIndex: 1,
      explanationSteps: [
        '4 quarters (25 × 4) = 100',
        '2 more quarters (25 × 2) = 50',
        '100 + 50 = 150',
        'Therefore, 25 × 6 = 150!'
      ],
      hintText: '25 × 4 = 100. Add two more 25s.',
      xpReward: 35,
      coinReward: 15,
      gemReward: 1,
    ),
    QuestionModel(
      id: 'w2_l3_q5',
      topic: 'Multiplication',
      difficulty: 'Intermediate',
      questionText: 'What is 32 × 3?',
      options: ['92', '96', '98', '94'],
      correctAnswerIndex: 1,
      explanationSteps: [
        '30 × 3 = 90',
        '2 × 3 = 6',
        '90 + 6 = 96',
        'Therefore, 32 × 3 = 96!'
      ],
      hintText: '30 × 3 = 90. Add 6.',
      xpReward: 35,
      coinReward: 15,
      gemReward: 1,
    ),
  ];

  // World 2 - Level 4: Two-Digit Division
  static const List<QuestionModel> world2Level4Questions = [
    QuestionModel(
      id: 'w2_l4_q1',
      topic: 'Division',
      difficulty: 'Intermediate',
      questionText: 'What is 72 ÷ 4?',
      options: ['16', '18', '20', '14'],
      correctAnswerIndex: 1,
      explanationSteps: [
        'Halve twice:',
        '72 ÷ 2 = 36',
        '36 ÷ 2 = 18',
        'Therefore, 72 ÷ 4 = 18!'
      ],
      hintText: 'Half of 72 is 36. Half of 36 is 18.',
      xpReward: 30,
      coinReward: 12,
      gemReward: 1,
    ),
    QuestionModel(
      id: 'w2_l4_q2',
      topic: 'Division',
      difficulty: 'Intermediate',
      questionText: 'Calculate: 96 ÷ 6',
      options: ['14', '16', '18', '20'],
      correctAnswerIndex: 1,
      explanationSteps: [
        'Break 96 into 60 + 36:',
        '60 ÷ 6 = 10',
        '36 ÷ 6 = 6',
        '10 + 6 = 16',
        'Therefore, 96 ÷ 6 = 16!'
      ],
      hintText: '60 ÷ 6 = 10. 36 ÷ 6 = 6.',
      xpReward: 30,
      coinReward: 12,
      gemReward: 1,
    ),
    QuestionModel(
      id: 'w2_l4_q3',
      topic: 'Division',
      difficulty: 'Intermediate',
      questionText: 'What is 84 ÷ 3?',
      options: ['26', '28', '30', '24'],
      correctAnswerIndex: 1,
      explanationSteps: [
        '60 ÷ 3 = 20',
        '24 ÷ 3 = 8',
        '20 + 8 = 28',
        'Therefore, 84 ÷ 3 = 28!'
      ],
      hintText: '60 ÷ 3 = 20. 24 ÷ 3 = 8.',
      xpReward: 35,
      coinReward: 15,
      gemReward: 1,
    ),
    QuestionModel(
      id: 'w2_l4_q4',
      topic: 'Division',
      difficulty: 'Intermediate',
      questionText: 'Solve: 105 ÷ 7',
      options: ['13', '15', '17', '14'],
      correctAnswerIndex: 1,
      explanationSteps: [
        '70 ÷ 7 = 10',
        '35 ÷ 7 = 5',
        '10 + 5 = 15',
        'Therefore, 105 ÷ 7 = 15!'
      ],
      hintText: '70 ÷ 7 = 10. 35 ÷ 7 = 5.',
      xpReward: 35,
      coinReward: 15,
      gemReward: 1,
    ),
    QuestionModel(
      id: 'w2_l4_q5',
      topic: 'Division',
      difficulty: 'Intermediate',
      questionText: 'What is 144 ÷ 8?',
      options: ['16', '18', '20', '22'],
      correctAnswerIndex: 1,
      explanationSteps: [
        '80 ÷ 8 = 10',
        '64 ÷ 8 = 8',
        '10 + 8 = 18',
        'Therefore, 144 ÷ 8 = 18!'
      ],
      hintText: '80 ÷ 8 = 10. 64 ÷ 8 = 8.',
      xpReward: 40,
      coinReward: 18,
      gemReward: 2,
    ),
  ];

  // World 2 - Level 5: Two-Digit Mixed Operations (Boss Level)
  static const List<QuestionModel> world2Level5Questions = [
    QuestionModel(
      id: 'w2_l5_q1',
      topic: 'Mixed Arithmetic',
      difficulty: 'Intermediate',
      questionText: 'What is 45 + 15 × 2?',
      options: ['65', '75', '120', '90'],
      correctAnswerIndex: 1,
      explanationSteps: [
        'Multiplication first: 15 × 2 = 30',
        'Then addition: 45 + 30 = 75',
        'Therefore, 45 + 15 × 2 = 75!'
      ],
      hintText: 'Multiply 15 × 2 first, then add 45.',
      xpReward: 40,
      coinReward: 20,
      gemReward: 2,
    ),
    QuestionModel(
      id: 'w2_l5_q2',
      topic: 'Mixed Arithmetic',
      difficulty: 'Intermediate',
      questionText: 'Calculate: (80 - 20) ÷ 4',
      options: ['12', '15', '18', '20'],
      correctAnswerIndex: 1,
      explanationSteps: [
        'Brackets first: 80 - 20 = 60',
        'Divide: 60 ÷ 4 = 15',
        'Therefore, (80 - 20) ÷ 4 = 15!'
      ],
      hintText: 'Subtract inside brackets first (60), then divide by 4.',
      xpReward: 40,
      coinReward: 20,
      gemReward: 2,
    ),
    QuestionModel(
      id: 'w2_l5_q3',
      topic: 'Mixed Arithmetic',
      difficulty: 'Intermediate',
      questionText: 'Solve: 100 - 6 × 12',
      options: ['28', '38', '48', '52'],
      correctAnswerIndex: 0,
      explanationSteps: [
        'Multiply first: 6 × 12 = 72',
        'Subtract: 100 - 72 = 28',
        'Therefore, 100 - 6 × 12 = 28!'
      ],
      hintText: '6 × 12 = 72. Subtract 72 from 100.',
      xpReward: 45,
      coinReward: 22,
      gemReward: 2,
    ),
    QuestionModel(
      id: 'w2_l5_q4',
      topic: 'Mixed Arithmetic',
      difficulty: 'Intermediate',
      questionText: 'What is (24 + 36) ÷ (12 - 7)?',
      options: ['10', '12', '14', '15'],
      correctAnswerIndex: 1,
      explanationSteps: [
        'Bracket 1: 24 + 36 = 60',
        'Bracket 2: 12 - 7 = 5',
        'Divide results: 60 ÷ 5 = 12',
        'Therefore, the answer is 12!'
      ],
      hintText: '24 + 36 = 60. 12 - 7 = 5. Divide 60 by 5.',
      xpReward: 50,
      coinReward: 25,
      gemReward: 3,
    ),
  ];
}

/// Helper class for generating additional dynamic single/double digit math questions
class QuestionGenerator {
  static final _random = Random();

  /// Generates a single-digit addition question
  static QuestionModel generateSingleDigitAddition(String id) {
    final a = _random.nextInt(9) + 1; // 1..9
    final b = _random.nextInt(9) + 1; // 1..9
    final correct = a + b;
    final options = _generateDistractors(correct);
    return QuestionModel(
      id: id,
      topic: 'Addition',
      difficulty: 'Beginner',
      questionText: 'What is $a + $b?',
      options: options.map((e) => e.toString()).toList(),
      correctAnswerIndex: options.indexOf(correct),
      explanationSteps: [
        'Add $a and $b together.',
        'Count $b steps forward from $a to get $correct.'
      ],
      hintText: 'Count forward $b from $a.',
      xpReward: 15,
      coinReward: 8,
      gemReward: 1,
    );
  }

  static List<int> _generateDistractors(int correct) {
    final set = <int>{correct};
    while (set.length < 4) {
      final offset = (_random.nextInt(5) + 1) * (_random.nextBool() ? 1 : -1);
      final val = max(1, correct + offset);
      set.add(val);
    }
    final list = set.toList()..shuffle(_random);
    return list;
  }
}
