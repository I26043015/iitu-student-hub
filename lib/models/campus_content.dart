import 'package:flutter/material.dart';

class Announcement {
  const Announcement({
    required this.id,
    required this.title,
    required this.category,
    required this.date,
    required this.preview,
    required this.detail,
    required this.icon,
  });

  final String id, title, category, date, preview, detail;
  final IconData icon;
}

// Extra fields retain the existing service detail and appointment flow.
class CampusService {
  const CampusService(
    this.id, this.name, this.description, this.location,
    this.openingHours, this.contact, this.icon, this.status, {
    this.destination = '/service-detail',
  });

  final String id, name, description, location, openingHours, contact, status;
  final IconData icon;
  final String destination;
  String get label => name;
}

// All notices, dates, locations and contacts below are demonstration data.
const campusAnnouncements = <Announcement>[
  Announcement(
    id: 'notice-double-degree-2026',
    title: 'Double-degree information session',
    category: 'International opportunities', date: '28 OCT 2026',
    preview: 'Learn how to prepare for a sample international study application.',
    detail: 'This demonstration session introduces a fictional double-degree '
        'application journey. Students can practise preparing a transcript, '
        'writing a motivation letter and comparing course plans. The sample '
        'session takes place in Room 301 at 15:00. Bring a list of questions '
        'about studying abroad. This is not an official IITU admission notice.',
    icon: Icons.public,
  ),
  Announcement(
    id: 'notice-cyber-lab-2026',
    title: 'Campus cybersecurity practice lab',
    category: 'Workshop', date: '29 OCT 2026',
    preview: 'Practise recognising phishing and protecting student accounts.',
    detail: 'In this fictional hands-on lab, students review sample phishing '
        'messages, discuss strong passwords and practise reporting a suspicious '
        'link. The sample location is Computer Lab 204 at 16:00. Bring a laptop; '
        'all activities use demonstration accounts. No real credentials are '
        'requested. This workshop listing is demonstration data.',
    icon: Icons.security_outlined,
  ),
  Announcement(
    id: 'notice-library-hours-2026',
    title: 'Library study spaces: exam-week hours',
    category: 'Library', date: '30 OCT 2026',
    preview: 'Check sample extended hours and quiet-study guidance.',
    detail: 'For this campus prototype, the fictional library study area is '
        'available from 08:00 to 21:00 during the sample exam week. Quiet desks '
        'are on Level 2, while group discussions use the labelled collaboration '
        'room. Keep walkways clear and return borrowed materials to the desk. '
        'These hours are illustrative; check official university channels '
        'before planning an actual visit.',
    icon: Icons.local_library_outlined,
  ),
  Announcement(
    id: 'notice-hackathon-2026',
    title: 'Almaty student hackathon team meetup',
    category: 'Technology', date: '31 OCT 2026',
    preview: 'Meet fictional teammates for a campus accessibility challenge.',
    detail: 'This sample meetup helps students form teams around a fictional '
        'campus accessibility challenge. Discuss an idea, choose a small '
        'prototype and divide design, development and presentation tasks. '
        'The demonstration meetup is in the Student Space at 14:00. Beginners '
        'are welcome. This notice does not register anyone for a real '
        'hackathon or represent an official event.',
    icon: Icons.code,
  ),
  Announcement(
    id: 'notice-career-cv-2026',
    title: 'Prepare your first internship CV',
    category: 'Career', date: '02 NOV 2026',
    preview: 'Bring a one-page draft and practise describing your projects.',
    detail: 'The fictional Career Services team offers a sample CV review '
        'session in Room 105 at 11:00. Students can practise summarising '
        'course projects, listing relevant skills and writing clear achievement '
        'statements. Bring a one-page draft containing fictional contact '
        'information for this exercise. No CV is sent to an employer; this '
        'announcement is demonstration data.',
    icon: Icons.work_outline,
  ),
  Announcement(
    id: 'notice-sports-2026',
    title: 'Student sports club open afternoon',
    category: 'Sports', date: '03 NOV 2026',
    preview: 'Explore sample badminton, basketball and fitness activities.',
    detail: 'Visit the fictional Sports Hall at 15:30 to learn about sample '
        'student activities. The demonstration programme includes badminton, '
        'basketball and a beginner fitness introduction. Wear comfortable '
        'clothes and discuss accessibility needs with the sample service desk. '
        'This is a fictional programme for the app and does not confirm '
        'access to any real campus facilities.',
    icon: Icons.sports_basketball_outlined,
  ),
  Announcement(
    id: 'notice-accommodation-2026',
    title: 'Accommodation application checklist',
    category: 'Student support', date: '04 NOV 2026',
    preview: 'Review a fictional checklist before contacting housing support.',
    detail: 'This demonstration checklist explains a sample accommodation '
        'enquiry. Prepare your preferred move-in date, study year and questions '
        'about shared facilities. The fictional housing desk is in Room 112 '
        'and offers guidance from 10:00 to 16:00 on weekdays. Do not upload '
        'identity documents through this prototype. Actual accommodation '
        'availability and rules must be checked with the university.',
    icon: Icons.home_outlined,
  ),
  Announcement(
    id: 'notice-wellbeing-2026',
    title: 'Wellbeing and study-planning drop-in',
    category: 'Wellbeing', date: '05 NOV 2026',
    preview: 'Explore sample support for balancing deadlines and student life.',
    detail: 'The eighth announcement describes a fictional wellbeing drop-in '
        'in Room 108 at 13:00. Students can discuss sample study-planning '
        'strategies, taking breaks and finding campus support. The session '
        'is an illustration of a campus notice, not a real appointment or '
        'counselling service. Open Counselling in Services to read the matching '
        'sample support information.',
    icon: Icons.favorite_border,
  ),
];

const campusServices = <CampusService>[
  CampusService('library', 'Library',
    'Find study materials, citation tools and sample quiet-study spaces.',
    'Sample: Learning centre, level 2', 'Sample: Mon–Fri, 09:00–19:00',
    'library@example.edu', Icons.local_library_outlined, 'Demonstration data'),
  CampusService('counselling', 'Counselling',
    'Learn about fictional wellbeing appointments and student support.',
    'Sample: Student centre, room 108', 'Sample: Mon–Fri, 10:00–16:00',
    'wellbeing@example.edu', Icons.favorite_border, 'Demonstration data'),
  CampusService('accommodation', 'Accommodation',
    'Read sample housing guidance, application steps and residence information.',
    'Sample: Student centre, room 112', 'Sample: Mon–Fri, 10:00–16:00',
    'housing@example.edu', Icons.home_outlined, 'Demonstration data'),
  CampusService('career', 'Career Services',
    'Prepare a CV, plan an internship search and practise interviews.',
    'Sample: Student centre, room 105', 'Sample: Mon–Fri, 10:00–17:00',
    'career@example.edu', Icons.work_outline, 'Demonstration data'),
  CampusService('sports', 'Sports',
    'Explore fictional sports clubs, equipment guidance and activity sessions.',
    'Sample: Sports hall, reception', 'Sample: Mon–Fri, 09:00–18:00',
    'sports@example.edu', Icons.sports_basketball_outlined, 'Demonstration data'),
  CampusService('it', 'IT Helpdesk',
    'Get guidance on campus Wi-Fi, account access and student devices.',
    'Sample: Main building, room 204', 'Sample: Mon–Fri, 09:00–18:00',
    'it-support@example.edu', Icons.wifi_outlined, 'Demonstration data'),
];

// Retain the original optional service destinations below the required grid.
const additionalCampusServices = <CampusService>[
  CampusService('facilities', 'Facilities',
    'Report a classroom issue or request help with campus equipment and spaces.',
    'Sample: Main building, reception', 'Sample: Mon–Fri, 09:00–18:00',
    'facilities@example.edu', Icons.apartment_outlined, 'Demonstration data'),
  CampusService('activities', 'Student activities',
    'Discover student communities, volunteering and event opportunities.',
    'Sample: Student space, level 1', 'Sample: Mon–Fri, 10:00–17:00',
    'activities@example.edu', Icons.groups_outlined, 'Demonstration data'),
  CampusService('academic', 'Academic support',
    'Ask for guidance on study planning, course choices and academic enquiries.',
    'Sample: Academic office, room 301', 'Sample: Mon–Fri, 09:00–17:00',
    'academic@example.edu', Icons.school_outlined, 'Demonstration data'),
];
