const Engine = {
  current: "home",

  open(viewName) {
    const views = document.querySelectorAll(".view");
    views.forEach(v => v.classList.remove("active"));

    const target = document.querySelector(`[data-view="${viewName}"]`);
    if (!target) {
      console.error("View not found:", viewName);
      return;
    }

    target.classList.add("active");
    this.current = viewName;
  }
};
