package class_t;

public class Class_t {
    // 수업의 객체 정보
    private String class_id;
    private String class_no;
    private String course_id;
    private String name;
    private String major_id;
    private String class_year;
    private String credit;

    public Class_t(String class_id, String class_no, String course_id, String name, String major_id, String class_year, String credit) {
        this.class_id = class_id;
        this.class_no = class_no;
        this.course_id = course_id;
        this.name = name;
        this.major_id = major_id;
        this.class_year = class_year;
        this.credit = credit;
        this.lecturer_id = lecturer_id;
        this.person_max = person_max;
        this.opened = opened;
        this.room_id = room_id;
    }


    public String getClass_id() {
        return class_id;
    }

    public void setClass_id(String class_id) {
        this.class_id = class_id;
    }

    public String getClass_no() {
        return class_no;
    }

    public void setClass_no(String class_no) {
        this.class_no = class_no;
    }

    public String getCourse_id() {
        return course_id;
    }

    public void setCourse_id(String course_id) {
        this.course_id = course_id;
    }

    public String getName() {
        return name;
    }

    public void setName(String name) {
        this.name = name;
    }

    public String getMajor_id() {
        return major_id;
    }

    public void setMajor_id(String major_id) {
        this.major_id = major_id;
    }

    public String getClass_year() {
        return class_year;
    }

    public void setClass_year(String class_year) {
        this.class_year = class_year;
    }

    public String getCredit() {
        return credit;
    }

    public void setCredit(String credit) {
        this.credit = credit;
    }

    public String getLecturer_id() {
        return lecturer_id;
    }

    public void setLecturer_id(String lecturer_id) {
        this.lecturer_id = lecturer_id;
    }

    public String getPerson_max() {
        return person_max;
    }

    public void setPerson_max(String person_max) {
        this.person_max = person_max;
    }

    public String getOpened() {
        return opened;
    }

    public void setOpened(String opened) {
        this.opened = opened;
    }

    public String getRoom_id() {
        return room_id;
    }

    public void setRoom_id(String room_id) {
        this.room_id = room_id;
    }

    private String lecturer_id;
    private String person_max;
    private String opened;
    private String room_id;
}
