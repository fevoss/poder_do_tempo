import streamlit as st
import matplotlib.pyplot as plt
import numpy as np
from matplotlib.ticker import FuncFormatter

# Função para calcular o tempo necessário para atingir cada marco de 100k
def calcular_investimento(aporte_mensal, taxa_anual):
    taxa_mensal = (1 + taxa_anual / 100) ** (1 / 12) - 1
    saldo = 0
    meses = 0
    marcos = []
    while saldo < 1_000_000:
        saldo += aporte_mensal
        saldo *= (1 + taxa_mensal)
        meses += 1
        if saldo >= len(marcos) * 100_000 + 100_000:
            marcos.append((meses, saldo))
    return marcos

# Configurações iniciais
st.title("Simulador de Crescimento Financeiro")
st.sidebar.header("Parâmetros")
aporte_mensal = st.sidebar.slider("Aporte Mensal (R$)", 100, 10_000, 500, step=100)
taxa_anual = st.sidebar.slider("Taxa de Juros Anual (%)", 1, 20, 12)

# Cálculo dos investimentos
marcos = calcular_investimento(aporte_mensal, taxa_anual)
meses, saldos = zip(*marcos)
anos = np.array(meses) / 12

# Função para formatar o eixo y
def formatar_eixo_y(valor, _):
    return f"{int(valor // 1_000)}k"

# Gráfico
fig, ax = plt.subplots(figsize=(10, 6), facecolor="black")
tempo = np.arange(0, meses[-1] + 1) / 12
saldo_total = [
    aporte_mensal * ((1 + ((1 + taxa_anual / 100) ** (1 / 12) - 1)) ** m - 1) / (taxa_anual / 1200)
    for m in range(meses[-1] + 1)
]
ax.plot(tempo, saldo_total, label="Saldo Total", color="cyan")

# Personalização do gráfico
ax.set_title("Crescimento do Investimento ao Longo do Tempo", color="white")
ax.set_xlabel("Tempo (anos)", color="white")
ax.set_ylabel("Saldo Acumulado (R$)", color="white")
ax.set_ylim(0, 1_000_000)
ax.grid(True, linestyle="--", alpha=0.5, color="gray", axis='x')
ax.xaxis.label.set_color("white")
ax.yaxis.label.set_color("white")
ax.tick_params(axis="x", colors="white")
ax.tick_params(axis="y", colors="white")
ax.yaxis.set_major_formatter(FuncFormatter(formatar_eixo_y))
fig.patch.set_facecolor("black")
ax.set_facecolor("black")


ano_anterior = 0
# Adicionando anotações e linhas verticais
for ano, saldo in zip(anos, saldos):
    ax.axvline(ano, color="gray", linestyle="--", alpha=0.5)
    ax.text(
        ano,
        saldo,  # Posiciona abaixo do eixo x
        f"{round(ano - ano_anterior, 2)} anos",
        color="white",
        fontsize=10,
        ha="center",
        va="center",
    )
    ano_anterior = ano

st.pyplot(fig)

# Exibição dos resultados
ano_anterior = 0
st.write(f"Com um aporte mensal de **R${aporte_mensal:,.2f}** e uma taxa de juros anual de **{taxa_anual}%**, você atingirá os seguintes marcos:")
for ano, saldo in zip(anos, saldos):
    st.write(f"- R$ {int(saldo/100_000) * 100000:,} em mais {(ano - ano_anterior):.2f} anos.".replace(",", "."))
    ano_anterior = ano
