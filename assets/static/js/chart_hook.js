import { Chart, registerables } from "chart.js";

Chart.register(...registerables);

let ChartJsHook = {
    mounted() {
        this.renderChart();

        this.handleEvent("add_chart_data", ({ target, label, datasets }) => {
            if (target && target !== this.el.id) {
                return;
            }
            this.addData(label, datasets);
        });
    },
    updated() {
        this.renderChart();
    },

    addData(label, datasets) {
        if (label) {
            this.chart.data.labels.push(label);
        }

        if (datasets && Array.isArray(datasets)) {
            datasets.forEach((datasetUpdate, index) => {
                const targetIndex =
                    datasetUpdate.datasetIndex !== undefined
                        ? datasetUpdate.datasetIndex
                        : index;
                if (
                    this.chart.data.datasets[targetIndex] &&
                    datasetUpdate.data !== undefined
                ) {
                    this.chart.data.datasets[targetIndex].data.push(
                        datasetUpdate.data,
                    );
                }
            });
        }

        this.chart.update("active");
    },

    renderChart() {
        const canvas = this.el.querySelector("canvas");
        const config = JSON.parse(this.el.dataset.config);
        const data = JSON.parse(this.el.dataset.data);

        if (this.chart) {
            this.chart.destroy();
        }
        const finalConfig = {
            ...config,
            data: data,
        };

        this.chart = new Chart(canvas, finalConfig);
    },

    destroyed() {
        if (this.chart) {
            this.chart.destroy();
        }
    },
};

export default ChartJsHook;
