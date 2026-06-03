# pipeline/steps/aggregate.py
import sqlite3
import pandas as pd
import matplotlib.pyplot as plt
import matplotlib.gridspec as gridspec
from matplotlib.backends.backend_pdf import PdfPages
from pathlib import Path
from datetime import date
from pipeline.config import DB_PATH, AGG_OUTPUT_DIR, AGG_SQL_DIR
from pipeline.logger import get_logger

log = get_logger(__name__)

def run_sql_file(sql_file: Path, con: sqlite3.Connection) -> None:
    log.info(f"  running {sql_file.name}")
    sql = sql_file.read_text(encoding="utf-8")
    con.executescript(sql)
    con.commit()

def export_to_csv(table_name: str, con: sqlite3.Connection) -> pd.DataFrame:
    out_path = AGG_OUTPUT_DIR / f"{table_name}.csv"
    df = pd.read_sql(f"SELECT * FROM {table_name}", con)
    df.to_csv(out_path, index=False)
    log.info(f"  exported {table_name} → {out_path.name} ({len(df):,} rows)")
    return df
##---------------------------------------------------
def generate_pdf_report(dfs: dict) -> None:
    from matplotlib.backends.backend_pdf import PdfPages
    import matplotlib.pyplot as plt
    from matplotlib import rcParams

    snapshot = date.today().strftime("%Y-%m-%d")
    pdf_path = AGG_OUTPUT_DIR / f"cms_hospital_typology_{snapshot}.pdf"

    cluster_df = dfs["agg_cluster_summary"]
    measure_df = dfs["agg_measure_summary"]
    geo_df     = dfs["agg_geo_rollup"]

    rcParams.update({
        "figure.facecolor": "white",
        "axes.facecolor":   "white",
        "axes.edgecolor":   "black",
        "axes.labelcolor":  "black",
        "xtick.color":      "black",
        "ytick.color":      "black",
        "text.color":       "black",
        "font.family":      "serif",
        "font.serif":       ["Georgia", "Times New Roman", "DejaVu Serif"],
        "grid.color":       "#cccccc",
        "grid.linestyle":   "--",
        "grid.alpha":       0.5,
    })

    def add_cover_page(pdf, snapshot):
        fig, ax = plt.subplots(figsize=(11, 8.5))
        fig.patch.set_facecolor("white")
        ax.set_facecolor("white")
        ax.axis("off")

        ax.text(0.5, 0.82, "CMS Hospital Typology",
                fontsize=28, fontweight="bold", ha="center", va="center",
                fontfamily="serif", color="black",
                transform=ax.transAxes)

        ax.text(0.5, 0.72, "Peer-Group Performance Report",
                fontsize=18, ha="center", va="center",
                fontfamily="serif", color="#444444",
                transform=ax.transAxes)

        ax.text(0.5, 0.62, f"Snapshot Date: {snapshot}",
                fontsize=13, ha="center", va="center",
                fontfamily="serif", color="#666666",
                transform=ax.transAxes)

        ax.plot([0.15, 0.85], [0.55, 0.55], color="black",
                linewidth=0.8, transform=ax.transAxes)

        ax.text(0.5, 0.42,
            "This report summarizes the CMS Hospital Typology pipeline output.\n"
            "3,115 U.S. acute-care hospitals are grouped into 7 structural peer clusters\n"
            "based on bed size, teaching status, urbanicity, case mix index, and safety-net burden.\n\n"
            "Performance metrics — readmissions, infections, patient satisfaction,\n"
            "Medicare spending, and mortality — are scored within peer groups,\n"
            "not against all hospitals nationally.\n\n"
            "This ensures fair, like-for-like benchmarking across the U.S. hospital landscape.",
            fontsize=11, ha="center", va="center",
            fontfamily="serif", linespacing=1.8, color="#222222",
            transform=ax.transAxes)

        ax.plot([0.15, 0.85], [0.10, 0.10], color="black",
                linewidth=0.8, transform=ax.transAxes)

        ax.text(0.5, 0.06,
                "Generated automatically by the CMS Hospital Typology Pipeline",
                fontsize=9, ha="center", va="center",
                fontfamily="serif", color="#888888",
                transform=ax.transAxes)

        fig.tight_layout()
        pdf.savefig(fig, facecolor="white")
        plt.close(fig)

    def add_table_page(pdf, title, subtitle, df, col_map):
        display = df[list(col_map.keys())].copy()
        display.columns = list(col_map.values())

        n_rows = len(display)
        fig_height = max(5, min(11, 2.5 + n_rows * 0.38))
        fig, ax = plt.subplots(figsize=(11, fig_height))
        fig.patch.set_facecolor("white")
        ax.set_facecolor("white")
        ax.axis("off")

        ax.text(0.0, 1.04, title,
                fontsize=14, fontweight="bold", fontfamily="serif",
                color="black", transform=ax.transAxes)

        ax.text(0.0, 1.00, subtitle,
                fontsize=9, color="#555555", fontfamily="serif",
                transform=ax.transAxes)

        ax.plot([0.0, 1.0], [0.97, 0.97], color="black",
                linewidth=0.6, transform=ax.transAxes)

        table = ax.table(
            cellText=display.values,
            colLabels=display.columns,
            cellLoc="center",
            loc="center"
        )
        table.auto_set_font_size(False)
        table.set_fontsize(9)
        table.scale(1, 1.5)
        table.auto_set_column_width(col=list(range(len(display.columns))))

        # Header row styling
        for j in range(len(display.columns)):
            table[0, j].set_facecolor("#222222")
            table[0, j].set_text_props(color="white", fontweight="bold",
                                        fontfamily="serif")

        # Alternating row shading
        for i in range(1, n_rows + 1):
            for j in range(len(display.columns)):
                table[i, j].set_facecolor("#f5f5f5" if i % 2 == 0 else "white")
                table[i, j].set_text_props(color="black", fontfamily="serif")

        ax.text(0.0, -0.03, f"Snapshot: {snapshot}  |  Rows: {n_rows}",
                fontsize=8, color="#888888", fontfamily="serif",
                transform=ax.transAxes)

        fig.tight_layout(pad=2.0)
        pdf.savefig(fig, facecolor="white")
        plt.close(fig)

    with PdfPages(pdf_path) as pdf:

        # Page 1 — Cover
        add_cover_page(pdf, snapshot)

        # Page 2 — Cluster structural profiles
        cluster_display = cluster_df.copy()
        cluster_display["avg_bed_count"]         = cluster_display["avg_bed_count"].round(0).astype(int)
        cluster_display["avg_cmi"]               = cluster_display["avg_cmi"].round(2)
        cluster_display["avg_safety_net_burden"] = cluster_display["avg_safety_net_burden"].round(1).astype(str) + "%"
        cluster_display["pct_teaching"]          = cluster_display["pct_teaching"].round(1).astype(str) + "%"
        cluster_display["pct_ipps_covered"]      = cluster_display["pct_ipps_covered"].round(1).astype(str) + "%"

        add_table_page(pdf,
            title="Cluster Summary — Structural Profiles",
            subtitle="One row per peer cluster. Structural variables only — performance is scored separately within each group.",
            df=cluster_display,
            col_map={
                "cluster_name":          "Cluster",
                "n_hospitals":           "Hospitals",
                "avg_bed_count":         "Avg Beds",
                "avg_cmi":               "Avg CMI",
                "avg_safety_net_burden": "Safety Net",
                "pct_teaching":          "Teaching %",
                "pct_ipps_covered":      "IPPS Covered",
            }
        )

    
       # Page 3 — Performance summary by cluster (proper 0-100 scale)
        import sqlite3 as _sqlite3
        _con = _sqlite3.connect(DB_PATH)
        perf = pd.read_sql("""
            SELECT 
                l.cluster_name,
                ROUND(AVG(s.cluster_pct), 1) as avg_median_score
            FROM model_hospital_scores s
            JOIN model_cluster_lookup l ON s.cluster_id = l.cluster_id
            GROUP BY l.cluster_name
            ORDER BY avg_median_score DESC
        """, _con)
        _con.close()
        perf["avg_median_score"] = perf["avg_median_score"].astype(str)

        add_table_page(pdf,
            title="Performance Summary — Avg Median Score by Cluster",
            subtitle="Scores are within-cluster percentiles (0–100). 100 = best performer among peers.",
            df=perf,
            col_map={
                "cluster_name":     "Cluster",
                "avg_median_score": "Avg Median Score",
            }
        )

        # Pages 4(+5) — Geographic summary
        geo = (
            geo_df.groupby("state")
            .agg(
                n_hospitals=("n_hospitals", "sum"),
                avg_performance=("avg_peer_pct", "mean"),
            )
            .round(1)
            .reset_index()
            .sort_values("avg_performance", ascending=False)
        )
        geo["avg_performance"] = geo["avg_performance"].astype(str)

        if len(geo) > 30:
            add_table_page(pdf,
                title="Geographic Summary — Performance by State (1/2)",
                subtitle="Avg peer percentile score across all clusters and measures within each state.",
                df=geo.iloc[:30],
                col_map={
                    "state":           "State",
                    "n_hospitals":     "Hospitals",
                    "avg_performance": "Avg Performance Score",
                }
            )
            add_table_page(pdf,
                title="Geographic Summary — Performance by State (2/2)",
                subtitle="Continued.",
                df=geo.iloc[30:],
                col_map={
                    "state":           "State",
                    "n_hospitals":     "Hospitals",
                    "avg_performance": "Avg Performance Score",
                }
            )
        else:
            add_table_page(pdf,
                title="Geographic Summary — Performance by State",
                subtitle="Avg peer percentile score across all clusters and measures within each state.",
                df=geo,
                col_map={
                    "state":           "State",
                    "n_hospitals":     "Hospitals",
                    "avg_performance": "Avg Performance Score",
                }
            )

    log.info(f"  PDF report generated → {pdf_path.name}")
      
#-------------------------------------------------------- if you wanna change the report : update above - def generate_pdf_report -

def run():
    log.info("aggregate started")
    AGG_OUTPUT_DIR.mkdir(parents=True, exist_ok=True)
    con = sqlite3.connect(DB_PATH)

    AGG_TABLES = [
        "agg_hospital_scorecard",
        "agg_cluster_summary",
        "agg_measure_summary",
        "agg_geo_rollup",
    ]

    try:
        log.info("Layer 5 - building output tables")
        sql_files = sorted(AGG_SQL_DIR.glob("*.sql"))
        if not sql_files:
            log.warning(f"No SQL files found in {AGG_SQL_DIR}")
        for sql_file in sql_files:
            run_sql_file(sql_file, con)

        log.info("Layer 5 - exporting to CSV")
        dfs = {}
        for table in AGG_TABLES:
            try:
                dfs[table] = export_to_csv(table, con)
            except Exception as e:
                log.error(f"  failed to export {table}: {e}")
                raise

        log.info("Layer 5 - generating PDF report")
        generate_pdf_report(dfs)

    finally:
        con.close()
        log.info(f"aggregate complete — outputs in {AGG_OUTPUT_DIR}")