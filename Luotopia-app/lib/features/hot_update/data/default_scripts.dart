/// 内置默认解析脚本（编译时嵌入，不可热更新）
/// JS 脚本必须定义 `parse(input)` 函数，接收 JSON 字符串，返回 JSON 字符串。
abstract class DefaultScripts {
  /// 课表解析器
  static const course = r'''
function parse(rawJson) {
  var data = JSON.parse(rawJson);
  var kbList = data.kbList || [];
  var result = [];
  for (var i = 0; i < kbList.length; i++) {
    var item = kbList[i];
    var name = item.kcmc || '';
    if (!name) continue;

    var classPeriod = (item.jcs || '').split('-');
    var classFrom = parseInt(classPeriod[0], 10) || -1;
    var classTo = classPeriod.length > 1 ? parseInt(classPeriod[1], 10) : classFrom;

    var weekday = parseInt(item.xqj, 10) || -1;
    if (weekday === 7) weekday = 0;

    var weeks = parseWeeks(item.zcd || '');

    result.push(JSON.stringify({
      name: name,
      courseId: item.jxbmc || '',
      weekday: weekday,
      classFrom: classFrom,
      classTo: classTo,
      location: item.cdmc || '',
      instructor: item.xm || '',
      instructorType: item.zcmc || '',
      courseType: item.kcxz || '',
      credit: parseFloat(item.xf || '0'),
      weeks: weeks
    }));
  }
  var studentId = data.xsxx ? (data.xsxx.XH || data.xsxx.XH_ID || '') : '';
  return JSON.stringify({ courses: result, studentId: studentId });
}

function parseWeeks(weekStr) {
  if (!weekStr) return [];
  var result = [];
  var parts = weekStr.split(',');
  for (var p = 0; p < parts.length; p++) {
    var seg = parts[p].trim();
    if (!seg) continue;
    var odd = seg.indexOf('单') !== -1;
    var even = seg.indexOf('双') !== -1;
    var nums = seg.match(/\d+/g);
    if (!nums) continue;
    var start = parseInt(nums[0], 10);
    var end = nums.length > 1 ? parseInt(nums[1], 10) : start;
    for (var w = start; w <= end; w++) {
      if (odd && w % 2 === 0) continue;
      if (even && w % 2 === 1) continue;
      if (result.indexOf(w) === -1) result.push(w);
    }
  }
  result.sort(function(a, b) { return a - b; });
  return result;
}
''';

  /// 成绩解析器
  static const score = r'''
function parse(rawJson) {
  var data = JSON.parse(rawJson);
  var items = data.items || [];
  var scores = [];
  var userInfo = { college: '', major: '', name: '', studentId: '' };

  for (var i = 0; i < items.length; i++) {
    var item = items[i];

    if (item.xh && item.xh !== '' && !userInfo.studentId) {
      userInfo = {
        college: item.jgmc || '',
        major: item.zymc || '',
        name: item.xm || '',
        studentId: item.xh || ''
      };
    }

    var year = parseInt(item.xnm, 10);
    var apiSem = parseInt(item.xqm, 10);
    var credit = parseFloat(item.xf || '0');
    var score = parseInt(item.bfzcj, 10);

    if (year <= 0 || isNaN(credit) || isNaN(score) || score <= 0) continue;

    var semester = 1;
    if (apiSem === 3) semester = 1;
    else if (apiSem === 12) semester = 2;
    else if (apiSem === 16) semester = 3;

    scores.push({
      year: year,
      semester: semester,
      name: item.kcmc || '',
      courseId: item.jxbmc || '',
      instructor: item.jsxm || '',
      credit: credit,
      courseType: item.kcxzmc || '',
      score: score,
      courseCollege: item.kkbmmc || ''
    });
  }

  return JSON.stringify({ scores: scores, userInfo: userInfo });
}
''';
}
