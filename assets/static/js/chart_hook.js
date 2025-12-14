import { Chart, registerables } from "chart.js";
import ChartDataLabels from "chartjs-plugin-datalabels";

Chart.register(...registerables);
Chart.register(ChartDataLabels);
Chart.defaults.plugins.datalabels.display = false;
Chart.defaults.plugins.tooltip.callbacks.label = function (context) {
    if (context.dataset && context.dataset.data[context.dataIndex].label) {
        const label = context.dataset.data[context.dataIndex].label;
        console.log(context);
        return `${label}: ${context.formattedValue}`;
        // return default_label_formatter(context);
    }
    console.log("default");
    return undefined;
};

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
