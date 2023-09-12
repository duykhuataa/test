package dao;

import controller.ResourceController;
import database.DBContext;
import java.sql.PreparedStatement;
import java.sql.ResultSet;
import java.sql.SQLException;
import java.util.ArrayList;
import model.Course;

public class CourseDAO extends DBContext {

  public ArrayList<Course> getCourseList() {
    ArrayList<Course> courseList = new ArrayList<>();

    try {
      String strQuery = "SELECT * FROM dbo.Course";
      PreparedStatement stm = connection.prepareStatement(strQuery);

      ResultSet rs = stm.executeQuery();
      while (rs.next()) {
        courseList.add(new Course(
                rs.getInt(1),
                rs.getString(2),
                rs.getString(3),
                rs.getInt(4),
                rs.getInt(5)
        ));
      }
    } catch (SQLException e) {
      e.printStackTrace();
    }
    return courseList;
  }

  public Course getCourseByCourseId(String courseId) {
    try {
      String strQuery = "SELECT * \n"
              + "FROM dbo.Course\n"
              + "WHERE CourseID = ?";
      PreparedStatement stm = connection.prepareStatement(strQuery);
      stm.setString(1, courseId);

      ResultSet rs = stm.executeQuery();
      if (rs.next()) {
        return new Course(
                rs.getInt(1),
                rs.getString(2),
                rs.getString(3),
                rs.getInt(4),
                rs.getInt(5)
        );
      }
    } catch (SQLException e) {
      e.printStackTrace();
    }
    return null;
  }

  public ArrayList<Course> getCourseListByTeacherId(int id) {
    ArrayList<Course> courseList = new ArrayList<>();

    try {
      String strQuery = "SELECT * FROM dbo.Course WHERE TeacherID = ?";
      PreparedStatement stm = connection.prepareStatement(strQuery);
      stm.setInt(1, id);

      ResultSet rs = stm.executeQuery();
      while (rs.next()) {
        courseList.add(new Course(
                rs.getInt(1),
                rs.getString(2),
                rs.getString(3),
                rs.getInt(4),
                rs.getInt(5)
        ));
      }
    } catch (SQLException e) {
      e.printStackTrace();
    }
    return courseList;
  }

  public boolean isHavePermission(int teacherId, int courseId) {
    ArrayList<Integer> courseIdList = new ArrayList<>();
    for (Course c : getCourseListByTeacherId(teacherId)) {
      courseIdList.add(c.getId());
    }
    return courseIdList.contains(courseId);
  }

  public void createCourse(String courseName, String description, int subjectId, int teacherId) {
    try {
      String strQuery = "INSERT INTO dbo.Course VALUES (?, ?, ?, ?)";
      PreparedStatement stm = connection.prepareStatement(strQuery);
      stm.setString(1, courseName);
      stm.setString(2, description);
      stm.setInt(3, subjectId);
      stm.setInt(4, teacherId);

      stm.execute();
    } catch (SQLException e) {
      e.printStackTrace();
    }
  }

  public void updateCourseName(String courseId, String newCourseName) {
    try {
      String strQuery = "UPDATE dbo.Course\n"
              + "SET CourseName = ?\n"
              + "WHERE CourseID = ?";
      PreparedStatement stm = connection.prepareStatement(strQuery);
      stm.setString(2, courseId);
      stm.setString(1, newCourseName);

      stm.execute();
    } catch (SQLException e) {
      e.printStackTrace();
    }
  }

  public void updateCourseDescription(String courseId, String newCourseDesc) {
    try {
      String strQuery = "UPDATE dbo.Course\n"
              + "SET CourseDescription = ?\n"
              + "WHERE CourseID = ?";
      PreparedStatement stm = connection.prepareStatement(strQuery);
      stm.setString(2, courseId);
      stm.setString(1, newCourseDesc);

      stm.execute();
    } catch (SQLException e) {
      e.printStackTrace();
    }
  }

//  DELETE CASCADEEEEE
  public void deleteCourse(int courseId) {
    try {
      ArrayList<Integer> rIdList = new ArrayList<>();
      ResultSet rs;
      PreparedStatement stm;
      String ar = "SELECT * FROM AnswerResource WHERE AnswerId IN ("
              + "SELECT AnswerId FROM Answer WHERE TestId IN ("
              + "SELECT TestId FROM Test WHERE CourseId = ?))";
      stm = connection.prepareStatement(ar);
      stm.setInt(1, courseId);
      rs = stm.executeQuery();
      while (rs.next()) {
        rIdList.add(rs.getInt(2));
      }
      
      String a = "DELETE FROM Answer WHERE TestId IN ("
              + "SELECT TestId FROM Test WHERE CourseId = ?)";
      stm = connection.prepareStatement(a);
      stm.setInt(1, courseId);
      stm.execute();

      String tr = "SELECT * FROM TestResource WHERE TestId IN ("
              + "SELECT TestId FROM Test WHERE CourseId = ?)";
      stm = connection.prepareStatement(tr);
      stm.setInt(1, courseId);
      rs = stm.executeQuery();
      while (rs.next()) {
        rIdList.add(rs.getInt(2));
      }

      String t = "DELETE FROM Test WHERE CourseId = ?";
      stm = connection.prepareStatement(t);
      stm.setInt(1, courseId);
      stm.execute();

      String cr = "SELECT * FROM CourseResource WHERE CourseId = ?";
      stm = connection.prepareStatement(cr);
      stm.setInt(1, courseId);
      rs = stm.executeQuery();
      while (rs.next()) {
        rIdList.add(rs.getInt(2));
      }

      String c = "DELETE FROM Course WHERE CourseID = ?";
      stm = connection.prepareStatement(c);
      stm.setInt(1, courseId);
      stm.execute();
      
      for (int resourceId : rIdList) {
        new ResourceController().deleteResource(resourceId);
      }
      
    } catch (SQLException e) {
      e.printStackTrace();
    }
  }
}
