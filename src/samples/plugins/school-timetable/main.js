globalThis.luotopiaPlugin = {
  apiVersion: 1,
  render() { return view('点击读取已导入的武大课表；需先在应用中登录并导入。'); },
  async onAction(request, context) {
    try {
      const timetables = await context.host.schoolTimetable.listTimetables();
      if (!timetables.length) return view('暂无当前登录会话内导入的武大课表，请到应用课程表页面重新导入。');
      const id = typeof request.input.timetable === 'string' ? request.input.timetable : timetables[0].id;
      const courses = await context.host.schoolTimetable.getCourses({timetableId: id, limit: 50});
      return view('已导入的本地课表，共 ' + courses.total + ' 次课程；此处显示前 50 次。', timetables, id, courses.items);
    } catch (error) {
      return view(error.message === 'AUTH_REQUIRED' ? '请先在应用账户页面登录武大教务账户。' : '无法读取课表，请检查插件权限或重新打开。');
    }
  }
};
function view(message, timetables = [], selected = '', courses = []) {
  const nodes = [{type:'text',id:'status',text:message}];
  if (timetables.length) nodes.push({type:'select',id:'timetable',label:'教务课表',value:selected,options:timetables.map(t => ({value:t.id,label:t.name}))});
  nodes.push({type:'button',id:'load',label:'读取课表',actionId:'load'});
  if (courses.length) nodes.push({type:'list',id:'courses',items:courses.map(c => ({id:c.id,title:c.title,subtitle:[c.startAt,c.location,c.instructor].filter(Boolean).join(' · ')}))});
  return {state:null,view:{title:'我的教务课表',nodes}};
}
