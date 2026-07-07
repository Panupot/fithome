// Workout programs - FitHome

class ProgramExercise {
  final String exerciseId;
  final int sets;
  final int reps; // 0 = time based
  final int seconds; // 0 = rep based
  final int restSec;

  const ProgramExercise({
    required this.exerciseId,
    required this.sets,
    this.reps = 0,
    this.seconds = 0,
    this.restSec = 45,
  });
}

class ProgramDay {
  final String nameEn;
  final String nameTh;
  final List<ProgramExercise> items;

  const ProgramDay({
    required this.nameEn,
    required this.nameTh,
    required this.items,
  });
}

class Program {
  final String id;
  final String nameEn;
  final String nameTh;
  final String descEn;
  final String descTh;
  final int level; // 1-3
  final int weeks;
  final List<ProgramDay> days;

  const Program({
    required this.id,
    required this.nameEn,
    required this.nameTh,
    required this.descEn,
    required this.descTh,
    required this.level,
    required this.weeks,
    required this.days,
  });
}

const List<Program> programs = [
  // ============ 1. BEGINNER FULL BODY ============
  Program(
    id: 'beginner_4wk',
    nameEn: 'Beginner Full Body (4 weeks)',
    nameTh: 'มือใหม่ทั้งตัว (4 สัปดาห์)',
    descEn:
        '3 days per week, rest at least 1 day between sessions. Rotate day A, B, C. Focus on learning good form before adding reps.',
    descTh:
        'สัปดาห์ละ 3 วัน พักอย่างน้อย 1 วันระหว่างครั้ง สลับวัน A, B, C เน้นฟอร์มให้ถูกก่อนค่อยเพิ่มจำนวนครั้ง',
    level: 1,
    weeks: 4,
    days: [
      ProgramDay(
        nameEn: 'Day A - Foundations',
        nameTh: 'วัน A - พื้นฐาน',
        items: [
          ProgramExercise(exerciseId: 'jumping_jack', sets: 1, seconds: 60, restSec: 30),
          ProgramExercise(exerciseId: 'sit_to_stand', sets: 3, reps: 10, restSec: 45),
          ProgramExercise(exerciseId: 'incline_pushup', sets: 3, reps: 8, restSec: 45),
          ProgramExercise(exerciseId: 'glute_bridge', sets: 3, reps: 12, restSec: 45),
          ProgramExercise(exerciseId: 'dead_bug', sets: 3, reps: 10, restSec: 45),
          ProgramExercise(exerciseId: 'plank', sets: 3, seconds: 20, restSec: 45),
        ],
      ),
      ProgramDay(
        nameEn: 'Day B - Move More',
        nameTh: 'วัน B - ขยับมากขึ้น',
        items: [
          ProgramExercise(exerciseId: 'standing_march', sets: 1, seconds: 60, restSec: 30),
          ProgramExercise(exerciseId: 'squat', sets: 3, reps: 10, restSec: 45),
          ProgramExercise(exerciseId: 'knee_pushup', sets: 3, reps: 8, restSec: 45),
          ProgramExercise(exerciseId: 'bird_dog', sets: 3, reps: 10, restSec: 45),
          ProgramExercise(exerciseId: 'calf_raise', sets: 3, reps: 15, restSec: 30),
          ProgramExercise(exerciseId: 'crunch', sets: 3, reps: 12, restSec: 45),
        ],
      ),
      ProgramDay(
        nameEn: 'Day C - Mix It Up',
        nameTh: 'วัน C - ผสมผสาน',
        items: [
          ProgramExercise(exerciseId: 'arm_circles', sets: 1, seconds: 45, restSec: 20),
          ProgramExercise(exerciseId: 'reverse_lunge', sets: 3, reps: 8, restSec: 45),
          ProgramExercise(exerciseId: 'superman', sets: 3, reps: 10, restSec: 45),
          ProgramExercise(exerciseId: 'ytw_raise', sets: 3, reps: 6, restSec: 45),
          ProgramExercise(exerciseId: 'wall_sit', sets: 3, seconds: 25, restSec: 45),
          ProgramExercise(exerciseId: 'inchworm', sets: 2, reps: 6, restSec: 45),
        ],
      ),
    ],
  ),

  // ============ 2. HIIT FAT BURN ============
  Program(
    id: 'hiit_burn',
    nameEn: 'HIIT Fat Burn (4 weeks)',
    nameTh: 'HIIT เผาผลาญไขมัน (4 สัปดาห์)',
    descEn:
        '4 days per week, about 20 minutes. Work 40 seconds, rest 20 seconds. Go at your own pace - quality over speed.',
    descTh:
        'สัปดาห์ละ 4 วัน ครั้งละประมาณ 20 นาที ออกแรง 40 วินาที พัก 20 วินาที ทำตามจังหวะตัวเอง เน้นคุณภาพมากกว่าความเร็ว',
    level: 2,
    weeks: 4,
    days: [
      ProgramDay(
        nameEn: 'HIIT 1 - Total Body',
        nameTh: 'HIIT 1 - ทั้งตัว',
        items: [
          ProgramExercise(exerciseId: 'jumping_jack', sets: 3, seconds: 40, restSec: 20),
          ProgramExercise(exerciseId: 'squat', sets: 3, seconds: 40, restSec: 20),
          ProgramExercise(exerciseId: 'mountain_climber', sets: 3, seconds: 40, restSec: 20),
          ProgramExercise(exerciseId: 'pushup', sets: 3, seconds: 40, restSec: 20),
          ProgramExercise(exerciseId: 'high_knees', sets: 3, seconds: 40, restSec: 20),
        ],
      ),
      ProgramDay(
        nameEn: 'HIIT 2 - Legs on Fire',
        nameTh: 'HIIT 2 - เน้นขา',
        items: [
          ProgramExercise(exerciseId: 'butt_kicks', sets: 3, seconds: 40, restSec: 20),
          ProgramExercise(exerciseId: 'jump_squat', sets: 3, seconds: 40, restSec: 20),
          ProgramExercise(exerciseId: 'lunge', sets: 3, seconds: 40, restSec: 20),
          ProgramExercise(exerciseId: 'skater_jump', sets: 3, seconds: 40, restSec: 20),
          ProgramExercise(exerciseId: 'wall_sit', sets: 3, seconds: 40, restSec: 20),
        ],
      ),
      ProgramDay(
        nameEn: 'HIIT 3 - Core Crusher',
        nameTh: 'HIIT 3 - เน้นแกนกลาง',
        items: [
          ProgramExercise(exerciseId: 'high_knees', sets: 3, seconds: 40, restSec: 20),
          ProgramExercise(exerciseId: 'bicycle_crunch', sets: 3, seconds: 40, restSec: 20),
          ProgramExercise(exerciseId: 'plank_up_down', sets: 3, seconds: 40, restSec: 20),
          ProgramExercise(exerciseId: 'russian_twist', sets: 3, seconds: 40, restSec: 20),
          ProgramExercise(exerciseId: 'flutter_kick', sets: 3, seconds: 40, restSec: 20),
        ],
      ),
      ProgramDay(
        nameEn: 'HIIT 4 - Finisher',
        nameTh: 'HIIT 4 - ปิดท้ายสัปดาห์',
        items: [
          ProgramExercise(exerciseId: 'inchworm', sets: 3, seconds: 40, restSec: 20),
          ProgramExercise(exerciseId: 'burpee', sets: 3, seconds: 40, restSec: 20),
          ProgramExercise(exerciseId: 'bear_crawl', sets: 3, seconds: 40, restSec: 20),
          ProgramExercise(exerciseId: 'shoulder_tap', sets: 3, seconds: 40, restSec: 20),
          ProgramExercise(exerciseId: 'squat_hold_pulse', sets: 3, seconds: 40, restSec: 20),
        ],
      ),
    ],
  ),

  // ============ 3. HOME MUSCLE BUILDER ============
  Program(
    id: 'muscle_home',
    nameEn: 'Home Muscle Builder (4 weeks)',
    nameTh: 'สร้างกล้ามที่บ้าน (4 สัปดาห์)',
    descEn:
        '4 days per week: Upper / Lower / Rest / Upper / Lower. Take each set close to muscle failure. Rest 60-90 seconds between sets.',
    descTh:
        'สัปดาห์ละ 4 วัน: ท่อนบน / ท่อนล่าง / พัก / ท่อนบน / ท่อนล่าง เล่นแต่ละเซ็ตให้ใกล้หมดแรง พักระหว่างเซ็ต 60-90 วินาที',
    level: 3,
    weeks: 4,
    days: [
      ProgramDay(
        nameEn: 'Upper 1 - Push Focus',
        nameTh: 'ท่อนบน 1 - เน้นดัน',
        items: [
          ProgramExercise(exerciseId: 'pushup', sets: 4, reps: 12, restSec: 60),
          ProgramExercise(exerciseId: 'pike_pushup', sets: 3, reps: 10, restSec: 60),
          ProgramExercise(exerciseId: 'wide_pushup', sets: 3, reps: 10, restSec: 60),
          ProgramExercise(exerciseId: 'tricep_dips', sets: 3, reps: 12, restSec: 60),
          ProgramExercise(exerciseId: 'plank', sets: 3, seconds: 40, restSec: 45),
        ],
      ),
      ProgramDay(
        nameEn: 'Lower 1 - Strength',
        nameTh: 'ท่อนล่าง 1 - ความแข็งแรง',
        items: [
          ProgramExercise(exerciseId: 'squat', sets: 4, reps: 15, restSec: 60),
          ProgramExercise(exerciseId: 'bulgarian_split_squat', sets: 3, reps: 8, restSec: 60),
          ProgramExercise(exerciseId: 'glute_bridge', sets: 3, reps: 15, restSec: 60),
          ProgramExercise(exerciseId: 'calf_raise', sets: 4, reps: 15, restSec: 45),
          ProgramExercise(exerciseId: 'hollow_hold', sets: 3, seconds: 25, restSec: 45),
        ],
      ),
      ProgramDay(
        nameEn: 'Upper 2 - Pull and Shoulders',
        nameTh: 'ท่อนบน 2 - ดึงและไหล่',
        items: [
          ProgramExercise(exerciseId: 'table_row', sets: 4, reps: 8, restSec: 60),
          ProgramExercise(exerciseId: 'diamond_pushup', sets: 3, reps: 8, restSec: 60),
          ProgramExercise(exerciseId: 'ytw_raise', sets: 3, reps: 8, restSec: 60),
          ProgramExercise(exerciseId: 'reverse_snow_angel', sets: 3, reps: 10, restSec: 60),
          ProgramExercise(exerciseId: 'side_plank', sets: 3, seconds: 25, restSec: 45),
        ],
      ),
      ProgramDay(
        nameEn: 'Lower 2 - Power',
        nameTh: 'ท่อนล่าง 2 - พลัง',
        items: [
          ProgramExercise(exerciseId: 'jump_squat', sets: 4, reps: 10, restSec: 60),
          ProgramExercise(exerciseId: 'step_up', sets: 3, reps: 10, restSec: 60),
          ProgramExercise(exerciseId: 'single_leg_bridge', sets: 3, reps: 10, restSec: 60),
          ProgramExercise(exerciseId: 'side_lunge', sets: 3, reps: 10, restSec: 60),
          ProgramExercise(exerciseId: 'leg_raise', sets: 3, reps: 12, restSec: 45),
        ],
      ),
    ],
  ),
];
