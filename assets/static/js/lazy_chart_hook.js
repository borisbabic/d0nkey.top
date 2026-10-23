// Loads chart.js only when a chart is actually rendered on the page
let chartHookPromise = null;
const loadChartHook = () => {
  if (!chartHookPromise) {
    chartHookPromise = import("./chart_hook.js").then((m) => m.default);
  }
  return chartHookPromise;
};

const LazyChartJsHook = {
  mounted() {
    loadChartHook().then((hook) => {
      if (this.isDestroyed) return;
      const { mounted, updated, destroyed, ...helpers } = hook;
      Object.assign(this, helpers);
      this.impl = { mounted, updated, destroyed };
      mounted.call(this);
    });
  },
  updated() {
    if (this.impl) this.impl.updated.call(this);
  },
  destroyed() {
    this.isDestroyed = true;
    if (this.impl) this.impl.destroyed.call(this);
  },
};

export default LazyChartJsHook;
