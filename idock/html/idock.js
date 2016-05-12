function toggle_visibility_tbody(id, linkid) {
  var e = document.getElementById(id);
  var lnk = document.getElementById(linkid);
  if(e.style.display == 'table-row-group') {
    e.style.display = 'none';
    lnk.innerHTML = lnk.innerHTML.replace('Hide', 'Show');
  } else {
    e.style.display = 'table-row-group';
    lnk.innerHTML = lnk.innerHTML.replace('Show', 'Hide');
  }
}
