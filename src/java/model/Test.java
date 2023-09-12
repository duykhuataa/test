package model;

import dao.ClassDAO;
import dao.TestDAO;
import java.sql.Timestamp;
import java.text.SimpleDateFormat;
import java.time.Duration;
import java.time.LocalDateTime;
import java.util.Date;

public class Test {

//  hardcoded
//  PLEASE dont touch
  public static final String ONGOING = "Ongoing", NOT_GRADED = "Not graded",
          GRADED = "Graded";

  int testId;
  String testName;
  int courseId, classId;
  Timestamp date;
  String status = ONGOING;

  public Test() {
  }

  public Test(int testId, String testName, int courseId, int classId, Timestamp date, String status) {
    this.testId = testId;
    this.testName = testName;
    this.courseId = courseId;
    this.classId = classId;
    this.date = date;
    this.status = status;
    if (status.equals(ONGOING)) {
      if (isPassedDueDate()) {
        this.status = NOT_GRADED;
        new TestDAO().setStatus(testId, NOT_GRADED);
      }
    }
  }

  public int getTestId() {
    return testId;
  }

  public String getTestName() {
    return testName;
  }

  public int getCourseId() {
    return courseId;
  }

  public int getClassId() {
    return classId;
  }

  public String getClassName() {
    return new ClassDAO().getClassNameByClassId(classId);
  }

  public String getDate() {
    return new SimpleDateFormat("HH:mm dd/MM/yyyy").format(date);
  }

  public Timestamp getDateTimestamp() {
    return date;
  }

  public int getHour() {
    return date.getHours();
  }

  public int getMinute() {
    return date.getMinutes();
  }

  public int getDayOfMonth() {
    return date.toLocalDateTime().getDayOfMonth();
  }

  public int getMonth() {
    return date.getMonth() + 1;
  }

  public int getYear() {
    return date.getYear() + 1900;
  }

  public boolean isPassedDueDate() {
    Date current = new Date();
    Date timestampDate = new Date(date.getTime());

    return current.after(timestampDate);
  }

  public String getRemainingTime() {
    LocalDateTime now = LocalDateTime.now();
    LocalDateTime dueDateTime = date.toLocalDateTime();

    Duration duration = Duration.between(now, dueDateTime);
    String out = "";
    
    boolean haveDays = false;
    if (duration.toDays() != 0) {
      out = out + "~" + Math.abs(duration.toDays()) + "d ";
      haveDays = true;
    }
    if (duration.toHours() % 24 != 0) {
      out = out + Math.abs(duration.toHours()) % 24 + "h ";
    }
    if (duration.toMinutes() % 60 != 0) {
      if (haveDays == false) {
        out = out + Math.abs(duration.toMinutes()) % 60 + "m";
      }
    }
    return out + (isPassedDueDate() ? " ago" : "");
  }

  public String getStatus() {
    return status;
  }

//  get Bootstrap badge bgs
//  for front-end
//  possibile values: bg-warning, bg-success, bg-danger
  public String getBadgeBg() {
    switch (getStatus()) {
      case ONGOING:
        return "bg-warning text-dark";
      case NOT_GRADED:
        return "bg-danger";
      case GRADED:
        return "bg-success";
    }
    return "";
  }
}
