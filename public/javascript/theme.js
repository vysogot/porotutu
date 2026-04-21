(() => {
  const STORAGE_KEY = 'porotutu.theme';
  const root = document.documentElement;

  const apply = (theme) => {
    root.dataset.theme = theme;
    try { localStorage.setItem(STORAGE_KEY, theme); } catch (_) {}
  };

  document.addEventListener('click', (event) => {
    const toggle = event.target.closest('[data-theme-toggle]');
    if (!toggle) return;
    event.preventDefault();
    const next = root.dataset.theme === 'dark' ? 'light' : 'dark';
    apply(next);
  });
})();
