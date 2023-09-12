<%@ taglib prefix="c" uri="http://java.sun.com/jsp/jstl/core" %>
<%@page contentType="text/html" pageEncoding="UTF-8" %>
<%@ page import="model.*" %>

<!DOCTYPE html>
<html>

<head>
  <meta http-equiv="Content-Type" content="text/html; charset=UTF-8">
  <title>${course.getCourseName()}</title>

  <% 
    Teacher teacher = (Teacher) request.getSession().getAttribute("teacher"); 
    String courseId = (String) request.getAttribute("courseId");
    int testId = -1;
    if (request.getAttribute("testId") != null) {
      testId = Integer.parseInt((String) request.getAttribute("courseId"));
    }
  %>
  <script>
    function applyDateValues() {
      const now = new Date()

      const yearInput = document.getElementById("year");
      yearInput.value = now.getFullYear();
      yearInput.min = now.getFullYear();

      document.getElementById("month").value = now.getMonth() + 1;
      document.getElementById("day").value = now.getDate();
      document.getElementById('hour').value = now.getHours()
      document.getElementById('minute').value = now.getMinutes()
    }

    function checkInput() {
      const dayBox = document.getElementById('day')

      if (parseInt(dayBox.value) > parseInt(dayBox.max)) {
        dayBox.value = dayBox.max
      }

      if (document.getElementById('month').value > 12) {
        document.getElementById('month').value = 12
      }
    }

    function checkValidDate() {
      const now = new Date();

      const monthValue = parseInt(document.getElementById("month").value);
      const dayInput = document.getElementById("day");
      const dayValue = dayInput.value;

      dayInput.max = [1, 3, 5, 7, 8, 10, 12].includes(monthValue) ? 31 :
              [4, 6, 9, 11].includes(monthValue) ? 30 :
              ((now.getFullYear() % 4 == 0 && now.getFullYear() % 100 != 0) || now.getFullYear() % 400 == 0) ? 29 : 28;
    }
  </script>
  <script>
    function calcEstimatedTime() {
      checkValidDate()
      checkInput()
      var estimatedTimeBox = document.getElementById('estimatedTime')

      const day = document.getElementById('day').value
      const month = document.getElementById('month').value
      const year = document.getElementById('year').value
      const hour = document.getElementById('hour').value
      const minute = document.getElementById('minute').value

      if (day && month && year && hour && minute) {
        const now = new Date()

        const nowDay = now.getDate()
        const nowMonth = now.getMonth() + 1
        const nowYear = now.getFullYear()
        const nowHour = now.getHours()
        const nowMinute = now.getMinutes()

        const startDate = new Date(year, month - 1, day, hour, minute)
        const endDate = new Date(nowYear, nowMonth - 1, nowDay, nowHour, nowMinute)

        const state = endDate.getTime() - startDate.getTime() < 0 ? "" : "Past "
        const timeDiff = Math.abs(endDate.getTime() - startDate.getTime())

        if (timeDiff === 0) {
          estimatedTimeBox.style.color = ''
          estimatedTimeBox.innerHTML = 'Estimated time: [Now]'
          return
        }

        var diffDays = Math.floor(timeDiff / (1000 * 3600 * 24))
        var diffMonths = Math.floor(diffDays / 30)
        var diffYears = Math.floor(diffMonths / 12)
        var diffHours = Math.floor((timeDiff % (1000 * 3600 * 24)) / (1000 * 3600))
        var diffMinutes = Math.ceil((timeDiff % (1000 * 3600)) / (1000 * 60))

        let estimatedTime = ''
        if (diffYears > 0) {
          estimatedTime += diffYears + ((diffYears === 1) ? ' year ' : ' years ')
          diffDays -= 6
        }
        if (diffMonths % 12 > 0) {
          estimatedTime += (diffMonths % 12) + ((diffMonths % 12 === 1) ? ' month ' : ' months ')
        }
        if (diffDays % 30 > 0) {
          estimatedTime += (diffDays % 30) + ((diffDays % 30 === 1) ? ' day ' : ' days ')
        }
        if (diffHours > 0) {
          estimatedTime += diffHours + ((diffHours === 1) ? ' hour ' : ' hours ')
        }
        if (diffMinutes > 0 && diffMonths === 0) {
          estimatedTime += diffMinutes + ((diffMinutes === 1) ? ' minute ' : ' minutes ')
        }

        estimatedTimeBox.style.color = (state === "Past ") ? 'red' : ''
        estimatedTimeBox.innerHTML = 'Estimated time: ' + state + estimatedTime
      } else {
        estimatedTimeBox.innerHTML = ''
      }
    }
  </script>
</head>
<c:url value="/" var="home"></c:url>

<body onload='applyDateValues()' style='overflow-x: hidden;'>
    <!-- Navbar -->
  <jsp:include page="navbar.jsp"/>

  <div class="row">

    <!-- sidebar -->
    <div class="col-2 min-vh-100 position-fixed" style="background-color: #212529;">
      <div class="p-3">
        <ul class="list-unstyled">
          <li class="mb-1">
            <a href='./' class="btn btn-dark w-100" style="color: white;">
              <div class="row">
                <div class="col-2">
                  <span class='material-symbols-outlined'>home</span>
                </div>
                <div class="col-10">
                  <h5 class='text-start'>Home</h5>
                </div>
              </div>
            </a>
          </li>
          <li class="mb-1">
            <a href='./calendar' class="btn btn-dark w-100" style="color: white;" id='calendarHref'>
              <div class="row">
                <div class="col-2">
                  <span class='material-symbols-outlined'>calendar_month</span>
                </div>
                <div class="col-10">
                  <h5 class='text-start'>Calendar</h5>
                </div>
              </div>
            </a>
          </li>
          <script>
            const month = new Date().getMonth() + 1
            const year = new Date().getFullYear()
            document.getElementById('calendarHref').href = './calendar?month=' + month + '&year=' + year
          </script>

          <li class="mb-1">
            <button class="btn btn-toggle btn-dark w-100" data-bs-toggle="collapse" data-bs-target="#dashboard-collapse" style="color: white;">
              <div class="row">
                <div class="col-2">
                  <span class='material-symbols-outlined'>bookmark</span>
                </div>
                <div class="col-10">
                  <h5 class='text-start'>My courses</h5>
                </div>
              </div>
            </button>

            <div class="collapse show" id="dashboard-collapse">
              <ul class="list-unstyled overflow-y-auto" style="color: white; max-height: 60vh;">
                <c:forEach items="${courseList}" var="c">
                  <li class=''>
                    <a href="./course?action=details&courseId=${c.id}" class="btn w-100 btn-dark align-items-center ${c.getId() == courseId ? 'active' : ''}" style="font-size: medium; color: white; text-align: left;">
                      <div class="row align-items-center ms-0">
                        <div class="col-2">
                          <span class="${c.getId() == courseId ? 'material-icons' : 'material-symbols-outlined'} align-middle">school</span>
                        </div>
                        <div class="col-10">
                          ${c.getCourseName()}
                        </div>
                      </div>
                    </a>
                  </li>
                </c:forEach>
              </ul>
            </div>
          </li>
          <li class="mb-1" style='position: absolute; bottom: 4rem;'>
            <hr class='border w-100'>
            <button class="btn btn-dark w-100" style="color: white;">
              <div class="row">
                <div class="col-2">
                  <span class='material-symbols-outlined'>account_circle</span>
                </div>
                <div class="col-10">
                  <h5 class='text-start'>${teacher.getFullName()}</h5>
                </div>
              </div>
            </button>
          </li>
        </ul>
      </div>
    </div>

    <c:if test="${isHavePermission == false}">
      <div class="col-10 mt-3" style='margin-left: 16.667%;'>
        <div class="row">
          <center>
            <div class="ms-3" style='margin-top: 8rem;'>
              <!-- <h1 class="fa-solid fa-lock" style='font-size: 13rem; user-select: none; color: silver;'></h1> -->
              <span class='material-symbols-outlined' style='font-size: 13rem; user-select: none; color: silver;'>lock</span>
              <h3 style='user-select: none; color: silver;'>You don't have permission to access this Course. <a href="./">Go to Dashboard</a></h3>
            </div>
          </center>
        </div>
      </div>
    </c:if>

    <c:if test="${isHavePermission == true}">
      <div class="col-10 mt-2" style='margin-left: 16.667%;'>
        <div class="row ms-0">

          <!-- Course name header, Tests summary and Test details -->
          <div class="col-8">

            <!-- Course name -->
            <h1 class='ms-3 mb-3 mt-2' style='vertical-align: middle;'>
              <c:if test="${empty testId}">
                ${course.getCourseName()}
              </c:if>
              <c:if test="${not empty testId}">
                <a href="./course?action=details&courseId=${course.getId()}" style='text-decoration: none;'>
                  ${course.getCourseName()}
                </a>
              </c:if>
            </h1>

            <c:if test="${not empty testId}">
              <h4 class='ms-3 mb-3' style='margin-top: -1rem;'>
                /${testName}
              </h4>
            </c:if>

            <!-- Tests summary -->
            <div class="border rounded ps-3">
              <h4 class='mt-2'>Tests</h4>
              <c:if test="${empty testList}">
                <h1 class='fs-5' style='color: silver; user-select: none;'>
                  No tests available
                </h1>
              </c:if>

              <c:if test="${not empty testList}">
                <table class="table table-hover" style='margin-left: -1rem;' id='testListTable'>
                  <thead>
                    <tr>
                      <th class='th-sm' scope="col"><span class='ms-2'>Class</span></th>
                      <th scope="col">Test name</th>
                      <th scope="col">Due date</th>
                      <th scope="col">Time remaining</th>
                      <th scope='col'>Status</th>
                    </tr>
                  </thead>
                  <tbody>
                    <c:forEach items="${testList}" var="t">
                      <tr onclick='checkCourse(${t.getTestId()})' style='cursor: pointer;' class='${t.getTestId() == testId ? 'table-active' : ''}'>
                        <td scope='row'>
                          <span class='ms-2'>${t.getClassName()}</span>
                        </td>
                        <td>${t.getTestName()}</td>
                        <td>${t.getDate()}</td>
                        <td>
                          <c:choose>
                            <c:when test="${t.isPassedDueDate() && t.getStatus() == Test.NOT_GRADED}">
                              <span style='color: red;'>${t.getRemainingTime()}</span>
                            </c:when>
                            <c:when test="${t.isPassedDueDate() && t.getStatus() == Test.GRADED}">
                              <span style='color: silver;'>${t.getRemainingTime()}</span>
                            </c:when>
                            <c:when test="${!t.isPassedDueDate()}">
                              <span>${t.getRemainingTime()}</span>
                            </c:when>
                          </c:choose>
                        </td>                          
                        <td class='align-middle'>
                          <span class='badge ${t.getBadgeBg()}' style='vertical-align: middle;'>${t.getStatus()}</span>
                        </td>
                      </tr>
                    </c:forEach>
                  </tbody>
                </table>
                <script>
                  function checkCourse(testId) {
                    var currentUrl = new URL(document.location);
                    var params = new URLSearchParams(currentUrl.search);
                    if (params.has('testId')) {
                      params.set('testId', testId);
                    } else {
                      params.append('testId', testId);
                    }
                    var nextUrl = currentUrl.origin + currentUrl.pathname + '?' + params.toString();
                    window.location.href = nextUrl;
                  }
                </script>
              </c:if>

              <script>
                new DataTable('#testListTable', {
                  order: []
                })
              </script>

              <button class='btn btn-sm btn-outline-success mb-3 mt-1' style='width: 5rem;'
                      data-bs-toggle="modal" data-bs-target="#createTest">
                <i class='material-icons align-middle'>
                  add
                </i>
              </button>
              <div class="modal fade" id='createTest'>
                <div class="modal-dialog modal-dialog-centered">
                  <div class="modal-content">
                    <div class="modal-header">
                      <h1 class='modal-title fs-5'>Create a test</h1>
                      <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <form action="course" method="post" enctype='multipart/form-data'>
                      <input type="hidden" name="action" id="" value='createTest'>
                      <input type="hidden" name="queryString" value="${pageContext.request.queryString}" />
                      <input type="hidden" name="courseId" id="" value='${courseId}'>
                      <div class='modal-body'>
                        <div class="row">
                          <div class="col-8">
                            <label for="testName" class="form-label">Test name</label>
                            <div class="input-group">
                              <input type="text" name='testName' class="form-control" id="testName" required>
                            </div>
                          </div>
                          <div class="col-4">
                            <label for="groupName" class="form-label">Class</label>
                            <select name='classId' id='subject' class="form-control selectpicker border" data-live-search="true"
                                    style='overflow-y: auto; max-height: 200px;'>
                              <c:forEach items="${classList}" var="c">
                                <option value="${c.classId}" >${c.className}</option>
                              </c:forEach>
                            </select>
                          </div>
                        </div>
                        <div class="row">
                          <div class="col-8">
                            <label for="dueDate" class='form-label mt-3'>
                              <span>Due date [dd/mm/yyyy]</span>
                            </label>
                            <div class="input-group">
                              <input type="number" class="form-control" name='day' placeholder="Day" id ='day' min='1' onchange='calcEstimatedTime()'>
                              <span class="input-group-text">/</span>
                              <input type="number" class="form-control" name='month' placeholder="Month" id='month' min='1' max='12' onchange='calcEstimatedTime()'>
                              <span class="input-group-text">/</span>
                              <input type="number" class="form-control w-25" name='year' placeholder="Year" id='year' min='2023' onchange='calcEstimatedTime()'>
                            </div>
                          </div>

                          <div class="col-4">
                            <label for="dueDate" class='form-label mt-3'>Due time</label>
                            <div class="input-group">
                              <input type="number" class="form-control" name='hour' placeholder="hh" id='hour' value='0' min='0' max='23' onchange='calcEstimatedTime()'>
                              <span class="input-group-text">:</span>
                              <input type="number" class="form-control" name='minute' placeholder="mm" id='minute' value='0' min='0' max='59' onchange='calcEstimatedTime()'>
                            </div>
                          </div>
                        </div>
                        <div class="row">
                          <div class="col-8">
                            <div class='form-text align-middle' id='estimatedTime'>Estimated time: [Now]</div>
                          </div>
                          <div class="col-4">
                            <a href='#' style='color: white; text-decoration: none;' class='badge bg-primary form-text align-middle' id='' onclick='applyDateValues(); calcEstimatedTime()'>
                              <span>Reset</span>
                            </a>
                          </div>
                        </div>

                        <label for="testResource" class="form-label mt-3">Attach resources</label>
                        <input class="form-control" type="file" id="testResource" name='file' multiple>
                        <div class="form-text">
                          Maximum file size: 50MB
                        </div>
                      </div>
                      <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                        <button type="submit" id='createCourseBtn' class="btn btn-success">Create</button>
                      </div>
                    </form>
                  </div>
                </div>
              </div>

              <div class="modal fade" id='editTest'>
                <div class="modal-dialog modal-dialog-centered">
                  <div class="modal-content">
                    <div class="modal-header">
                      <h1 class='modal-title fs-5'>Test preferences</h1>
                      <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <form action="course" method="post">
                      <input type="hidden" name="action" id="" value='updateTest'>
                      <input type="hidden" name="queryString" value="${pageContext.request.queryString}" />
                      <input type="hidden" name="testId" id="" value='${testId}'>
                      <div class='modal-body'>
                        <div class="row">
                          <div class="col-8">
                            <label for="testName" class="form-label">Test name</label>
                            <div class="input-group">
                              <input type="text" name='testName' class="form-control" value='${testName}' id="testName" required>
                            </div>
                          </div>
                          <div class="col-4">
                            <label for="groupName" class="form-label">Class</label>
                            <select name='classId' id='subject' class="form-control selectpicker" data-live-search="true"
                                    style='overflow-y: auto; max-height: 200px;'>
                              <c:forEach items="${classList}" var="c">
                                <option value="${c.classId}" <c:if test="${c.classId == test.classId}">selected</c:if>>${c.className}</option>
                              </c:forEach>
                            </select>
                          </div>
                        </div>
                        <div class="row">
                          <div class="col-8">
                            <label for="dueDate" class='form-label mt-3'>
                              <span>Due date [dd/mm/yyyy]</span>
                            </label>
                            <div class="input-group">
                              <input type="number" class="form-control" name='day' 
                                      placeholder="Day" value='${test.getDayOfMonth()}' id ='day' min='1' onchange='calcEstimatedTime()'>
                              <span class="input-group-text">/</span>
                              <input type="number" class="form-control" name='month' 
                                      placeholder="Month" value='${test.getMonth()}' id='month' min='1' max='12' onchange='calcEstimatedTime()'>
                              <span class="input-group-text">/</span>
                              <input type="number" class="form-control w-25" name='year' 
                                      placeholder="Year" value='${test.getYear()}' id='year' min='2023' onchange='calcEstimatedTime()'>
                            </div>
                          </div>

                          <div class="col-4">
                            <label for="dueDate" class='form-label mt-3'>Due time</label>
                            <div class="input-group">
                              <input type="number" class="form-control" name='hour' 
                                      placeholder="hh" id='hour' value='${test.getHour()}'' min='0' max='23' onchange='calcEstimatedTime()'>
                              <span class="input-group-text">:</span>
                              <input type="number" class="form-control" name='minute' 
                                      placeholder="mm" id='minute' value='${test.getMinute()}' max='59' onchange='calcEstimatedTime()'>
                            </div>
                          </div>
                        </div>
                        <!-- <div class="row">
                          <div class="col-8">
                            <div class='form-text align-middle' id='estimatedTime'>Estimated time: [Now]</div>
                          </div>
                          <div class="col-4">
                            <a href='#' style='color: white; text-decoration: none;' class='badge bg-primary form-text align-middle' id='' onclick='applyDateValues(); calcEstimatedTime()'>
                              <span>Reset</span>
                            </a>
                          </div>
                        </div> -->
                      </div>
                      <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                        <button type="submit" id='createCourseBtn' class="btn btn-success">Update</button>
                      </div>
                    </form>
                  </div>
                </div>
              </div>
            </div>

            <!-- Test resources -->
            <c:if test="${not empty test}">
              <div class="rounded border mt-3">
                <div class="row">
                  <div class="col-7">
                    <h4 class='ms-3 mt-2'>Test resources</h4>
                    <c:if test="${empty testResourceList}">
                      <h1 class='ms-3 fs-5' style='color: silver; user-select: none;'>
                        No resources available
                      </h1>
                    </c:if>
                    <c:if test="${not empty testResourceList}">
                      <c:forEach items="${testResourceList}" var="r">
                        <div class="row">
                          <div class="col-10">
                            <div class="ms-3 mb-1">
                              <a href="./download?downloadKey=${r.getDownloadKey()}">
                                ${r.getName()}
                              </a>
                            </div>
                          </div>
                          <div class="col-2">
                            <span class='material-symbols-outlined'>${r.getExtensionIcon()}</span>
                          </div>
                        </div>
                      </c:forEach>
                    </c:if>
                    <div class="row">
                      <div class="col-8">
                        <button class='btn btn-sm btn-outline-success mb-3 mt-1 ms-3' style='width: 5rem;'
                                data-bs-toggle="modal" data-bs-target="#uploadTestResource">
                          <span class='material-icons align-middle'>
                            upload
                          </span>
                        </button>
                      </div>
                      <div class="col-4">
                        <c:if test="${not empty testResourceList}">
                          <button class='btn btn-sm btn-outline-danger mb-3 mt-1 ms-3' style='width: 5rem;'
                                  data-bs-toggle="modal" data-bs-target="#deleteTestResource">
                            <span class='material-icons align-middle'>
                              delete
                            </span>
                          </button>
                        </c:if>
                      </div>
                    </div>
                  </div> 
                  <div class="col-5">
                    <h4 class='ms-3 mt-2'>Test preferences</h4>
                    <div class="row">
                      <div class="col-6">
                        <button class='ms-3 mt-1 btn btn-outline-success material-symbols-outlined' style='width: 5rem;'
                                data-bs-toggle="modal" data-bs-target="#editTest">
                          settings
                        </button>
                      </div>
                      <div class="col-6">
                        <c:if test="${test.getStatus() == Test.NOT_GRADED}">
                          <form action="course" method='post'>
                            <input type="hidden" name="action" value='markTestAsGraded'>
                            <input type="hidden" name="queryString" value="${pageContext.request.queryString}">
                            <input type="hidden" name="testId" value='${testId}'>
                            <button class='ms-3 mt-1 btn btn-outline-success material-symbols-outlined' style='width: 5rem;' 
                              data-bs-toggle='tooltip' data-bs-title='Mark this Test as Graded' data-bs-placement='right'>
                              fact_check
                            </button>
                          </form>
                        </c:if>
                        <c:if test="${test.getStatus() == Test.GRADED}">
                          <form action="course" method='post'>
                            <input type="hidden" name="action" value='markTestAsNotGraded'>
                            <input type="hidden" name="queryString" value="${pageContext.request.queryString}">
                            <input type="hidden" name="testId" value='${testId}'>
                            <button class='ms-3 mt-1 btn btn-outline-danger material-symbols-outlined' style='width: 5rem;'
                              data-bs-toggle='tooltip' data-bs-title='Mark this Test as Not graded' data-bs-placement='right'>
                              remove_done
                            </button>
                          </form>
                        </c:if>
                      </div>
                    </div>
                  </div>
                </div>
              </div>
            </c:if>

            <div class="modal fade" id='uploadTestResource' data-bs-backdrop='static'>
              <div class="modal-dialog modal-dialog-centered">
                <div class="modal-content">
                  <div class="modal-header">
                    <h1 class='modal-title fs-5'>Upload test resources</h1>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                  </div>
                  <form action="course" method="post" enctype='multipart/form-data'>
                    <input type="hidden" name="action" id="" value='uploadTestResource'>
                    <input type="hidden" name="queryString" value="${pageContext.request.queryString}" />
                    <input type="hidden" name="testId" id="" value='${testId}'>
                    <div class='modal-body'>
                      <label for="formFiles" class="form-label">You can choose multiple files</label>
                      <input class="form-control" type="file" id="formFiles" name='file' multiple>
                      <div class="form-text">
                        Maximum file size: 50MB
                      </div>
                    </div>
                    <div class="modal-footer">
                      <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                      <button type="submit" id='createCourseBtn' class="btn btn-success">Upload</button>
                    </div>
                  </form>
                </div>
              </div>
            </div>

            <div class="modal fade" id='deleteTestResource' data-bs-backdrop='static'>
              <div class="modal-dialog modal-dialog-centered">
                <div class="modal-content">
                  <div class="modal-header">
                    <h1 class='modal-title fs-5'>Delete test resources</h1>
                    <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                  </div>
                  <form action="course" method="post" name='resourceIdList'>
                    <input type="hidden" name="action" id="" value='deleteTestResource'>
                    <input type="hidden" name="queryString" value="${pageContext.request.queryString}" />
                    <input type="hidden" name="testId" id="" value='${testId}'>
                    <div class="modal-body">
                      <label for="form-check">Mark all the resources which you want to be deleted</label>
                      <div class="form-check mt-1" id='form-check'>
                        <c:forEach items="${testResourceList}" var="r">
                          <input class="form-check-input" type='checkbox' name='selectedResourceIds' value='${r.getId()}'>
                          <label for="${r.getName()}">
                            ${r.getName()}
                          </label>
                          <br>
                        </c:forEach>
                      </div>
                    </div>
                    <div class="modal-footer">
                      <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                      <button type="submit" id='createCourseBtn' class="btn btn-danger">Delete</button>
                    </div>
                  </form>
                </div>
              </div>
            </div>

            <!-- Answers details -->
            <c:if test="${not empty test}">
              <div class="rounded border mt-3 mb-3 ps-3">
                <h4 class='mt-2'>Student answers - For testing purposes</h4>
                <c:if test='${not empty answerList}'>
                  <table id='answerListTable' class='table table-hover' style='margin-left: -1rem;'>
                    <thead>
                      <tr>
                        <th scope='col' class='th-sm'>
                          <span class='ms-2'>Name</span>
                        </th>
                        <th scope='col'>Attachment</th>
                        <th scope='col'>Mark</th>
                      </tr>
                    </thead>
                    <tbody>
                      <c:forEach items="${answerList}" var="a">
                        <tr>
                          <td scope='row'>
                            <span class='ms-2 align-middle'>${a.getStudentName()}</span>
                          </td>
                          <td style='vertical-align: middle;'>
                            <a href='./download?downloadKey=${a.getDownloadKey()}'>
                              ${a.getResourceName()}
                            </a>
                          </td>
                          <td>
                            <form action="course" method="post">
                              <input type="hidden" name="action" value='gradeAnswer'>
                              <input type="hidden" name="answerId" value='${a.getAnswerId()}'>
                              <input type="hidden" name="queryString" value="${pageContext.request.queryString}" />
                              <div class="input-group">
                                <input type="number" step='0.01' name='mark' class="form-control w-25" value="${(a.getMark() == -1.0) ? '' : a.getMark()}" placeholder="Not graded">
                                <button class="btn btn-outline-success material-icons" type="submit">${(a.getMark() == -1.0) ? 'done' : 'edit'}</button>
                              </div>
                            </form>
                          </td>
                        </tr>
                      </c:forEach>
                    </tbody>
                  </table>
                </c:if>
                <c:if test="${empty answerList}">
                  <h1 class='fs-5' style='color: silver; user-select: none;'>
                    No answers submitted
                  </h1>
                </c:if>
                <button class='btn btn-sm btn-outline-success mb-3 mt-1' style='width: 5rem;'
                        data-bs-toggle="modal" data-bs-target="#createAnswer">
                  <span class='material-icons align-middle'>
                    add
                  </span>
                </button>
                <script>
                  new DataTable('#answerListTable');
                </script>
              </div>

              <div class="modal fade" id='createAnswer' data-bs-backdrop='static'>
                <div class="modal-dialog modal-dialog-centered">
                  <div class="modal-content">
                    <div class="modal-header">
                      <h1 class='modal-title fs-5'>Submit an Answer [Test purposes]</h1>
                      <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <form action="course" method="post" enctype='multipart/form-data'>
                      <input type="hidden" name="action" id="" value='createAnswer'>
                      <input type="hidden" name="queryString" value="${pageContext.request.queryString}" />
                      <input type="hidden" name="testId" id="" value='${testId}'>
                      <div class='modal-body'>
                        <label for="formStudent" class="form-label">Choose a student</label>
                        <select name="studentId" id="formStudent" class="form-control border selectpicker" data-live-search="true">
                          <c:forEach items="${studentList}" var="s">
                            <option value="${s.getId()}">${s.getId()} - ${s.getName()}</option>
                          </c:forEach>
                        </select>
                        <br>
                        <label for="formFiles" class="form-label">Choose 1 file to submit</label>
                        <input class="form-control" type="file" id="formFiles" name='file'>
                        <div class="form-text">
                          Maximum file size: 50MB
                        </div>
                      </div>
                      <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                        <button type="submit" id='createCourseBtn' class="btn btn-success">Submit</button>
                      </div>
                    </form>
                  </div>
                </div>
              </div>
            </c:if>
          </div>

          <!-- Resources and Preferences -->
          <div class="col-4">
            <!-- Resources -->
            <div class="rounded border mt-2">
              <h4 class='ms-3 mt-2'>Course resources</h4>

              <c:if test="${empty resourceList}">
                <h1 class='ms-3 fs-5' style='color: silver; user-select: none;'>
                  No resources available
                </h1>
              </c:if>
              <c:forEach items="${resourceList}" var="r">
                <div class="row">
                  <div class="col-10">
                    <div class="ms-3 mb-1">
                      <a href="./download?downloadKey=${r.getDownloadKey()}">
                        ${r.getName()}
                      </a>
                    </div>
                  </div>
                  <div class="col-2">
                    <span class='material-symbols-outlined'>${r.getExtensionIcon()}</span>
                  </div>
                </div>
              </c:forEach>

              <div class="row">
                <div class="col-8">
                  <button class='btn btn-sm btn-outline-success ms-3 mb-3 mt-2' style='width: 5rem;' data-bs-toggle='modal' data-bs-target='#uploadCourseResource' tabindex='-1'>
                    <i class='material-icons align-middle'>upload</i>
                  </button>
                </div>
                <div class="col-4">
                  <c:if test="${not empty resourceList}">
                    <button class='btn btn-sm btn-outline-danger ms-3 mb-3 mt-2' style='width: 5rem;' data-bs-toggle='modal' data-bs-target="#deleteCourseResource" tabindex='-1'>
                      <i class='material-icons align-middle'>delete</i>
                    </button>
                  </c:if>
                </div>
              </div>

              <div class="modal fade" id='uploadCourseResource' data-bs-backdrop='static'>
                <div class="modal-dialog modal-dialog-centered">
                  <div class="modal-content">
                    <div class="modal-header">
                      <h1 class='modal-title fs-5'>Upload resources</h1>
                      <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <form action="course" method="post" enctype='multipart/form-data'>
                      <input type="hidden" name="action" id="" value='uploadCourseResource'>
                      <input type="hidden" name="queryString" value="${pageContext.request.queryString}" />
                      <input type="hidden" name="courseId" id="" value='${courseId}'>
                      <div class='modal-body'>
                        <label for="formFiles" class="form-label">You can choose multiple files</label>
                        <input class="form-control" type="file" id="formFiles" name='file' multiple>
                        <div class="form-text">
                          Maximum file size: 50MB
                        </div>
                      </div>
                      <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                        <button type="submit" id='createCourseBtn' class="btn btn-success">Upload</button>
                      </div>
                    </form>
                  </div>
                </div>
              </div>

              <div class="modal fade" id='deleteCourseResource' data-bs-backdrop='static'>
                <div class="modal-dialog modal-dialog-centered">
                  <div class="modal-content">
                    <div class="modal-header">
                      <h1 class='modal-title fs-5'>Delete resources</h1>
                      <button type="button" class="btn-close" data-bs-dismiss="modal" aria-label="Close"></button>
                    </div>
                    <form action="course" method="post" name='resourceIdList'>
                      <input type="hidden" name="action" id="" value='deleteCourseResource'>
                      <input type="hidden" name="queryString" value="${pageContext.request.queryString}" />
                      <input type="hidden" name="courseId" id="" value='${courseId}'>
                      <div class="modal-body">
                        <label for="form-check">Mark all the resources which you want to be deleted</label>
                        <div class="form-check mt-1" id='form-check'>
                          <c:forEach items="${resourceList}" var="r">
                            <input class="form-check-input" type='checkbox' name='selectedResourceIds' value='${r.getId()}'>
                            <label for="${r.getName()}">
                              ${r.getName()}
                            </label>
                            <br>
                          </c:forEach>
                        </div>
                      </div>
                      <div class="modal-footer">
                        <button type="button" class="btn btn-secondary" data-bs-dismiss="modal">Close</button>
                        <button type="submit" id='createCourseBtn' class="btn btn-danger">Delete</button>
                      </div>
                    </form>
                  </div>
                </div>
              </div>
            </div>

            <!-- Preferences -->
            <div class="border rounded mt-3">
              <h4 class='ms-3 mt-2'>Preferences</h4>

              <!-- Update course name -->
              <!-- it's works, dont touch -->
              <div class="ms-3 mb-3">
                <label for="basic-url" class="form-label">Course name</label>
                <form action="course" method="post">
                  <input type="hidden" name="courseId" id="" value='<%=courseId%>'>
                  <input type="hidden" name="action" id="" value='updateCourseName'>
                  <input type="hidden" name="queryString" value="${pageContext.request.queryString}" />
                  <div class="input-group">
                    <input type="text" class="form-control" id="basic-url" name="courseName"
                            value='${course.getCourseName()}'>
                    <button class='btn btn-sm btn-outline-success border me-4' style='vertical-align: middle;'>
                      <span class='material-icons align-middle'>done</span>
                    </button>
                  </div>
                </form>
              </div>

              <!-- Update course desc -->
              <div class="ms-3 mb-3">
                <form action="course" method="post">
                  <input type="hidden" name="courseId" id="" value='<%=courseId%>'>
                  <input type="hidden" name="action" id="" value='updateCourseDesc'>
                  <input type="hidden" name="queryString" value="${pageContext.request.queryString}" />
                  <div class="input-group">
                    <input type="text" class="form-control" id="basic-url" name="courseDesc"
                            value='${course.getCourseDescription()}'>
                    <button class='btn btn-sm btn-outline-success border me-4' style='vertical-align: middle;'>
                      <span class='material-icons align-middle'>done</span>
                    </button>
                  </div>
                </form>
              </div>

              <div class="ms-3 mb-3">
                <div class="form-check form-switch">
                  <label class="form-check-label" for="switch">Visible to all students</label>
                  <input class="form-check-input" type="checkbox" role="switch" id="switch" checked>
                </div>
              </div>
              <hr>
              <!-- <div class="ms-3 mb-3">
                <form action="course" method="post">
                  <input type="hidden" name="action" value='deleteCourse'>
                  <input type="hidden" name="courseId" value='<%=courseId%>'>
                  <button class='btn btn-outline-danger'>Delete course</button>
                </form>
              </div> -->
            </div>
          </div>
        </div>
      </div>
    </c:if>
  </div>
  <script>
    var tooltipTriggerList = [].slice.call(document.querySelectorAll('[data-bs-toggle="tooltip"]'))
    var tooltipList = tooltipTriggerList.map(function (tooltipTriggerEl) {
      return new bootstrap.Tooltip(tooltipTriggerEl)
    })
  </script>
</body>

</html>