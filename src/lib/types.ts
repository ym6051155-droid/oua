export type Role = "student" | "professor" | "admin";
export type Profile = {
  id: string; full_name: string; email: string; role: Role; major: string | null;
  semester: number | null; whatsapp_number: string | null; department: string | null;
  is_approved: boolean; notification_preferences: Record<string, boolean>;
};
export type AcademicGroup = {
  id: string; name: string; subject_name: string; target_major: string;
  target_semester: number; created_at: string; created_by_prof_id: string;
};