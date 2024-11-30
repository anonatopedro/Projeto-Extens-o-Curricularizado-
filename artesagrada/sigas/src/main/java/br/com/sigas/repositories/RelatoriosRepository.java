package br.com.sigas.repositories;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.List;

import org.springframework.stereotype.Repository;

import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;

@Repository
public class RelatoriosRepository {

    @PersistenceContext
    private EntityManager entityManager;

    @SuppressWarnings("unchecked")
    public List<Object[]> findOperacoesPorPeriodo(LocalDate inicio, LocalDate fim) {
        return entityManager
                .createNativeQuery("SELECT * FROM vw_operacoes_periodo WHERE data_operacao BETWEEN :inicio AND :fim")
                .setParameter("inicio", inicio)
                .setParameter("fim", fim)
                .getResultList();
    }

    @SuppressWarnings("unchecked")
    public List<Object[]> findProdutosMaisVendidos(LocalDate inicio, LocalDate fim) {
        return entityManager
                .createNativeQuery(
                        "SELECT * FROM vw_produtos_mais_vendidos WHERE data_operacao BETWEEN :inicio AND :fim")
                .setParameter("inicio", inicio)
                .setParameter("fim", fim)
                .getResultList();
    }

    @SuppressWarnings("unchecked")
    public List<Object[]> findEstoqueAtual() {
        return entityManager.createNativeQuery("SELECT * FROM vw_estoque_atual").getResultList();
    }

    @SuppressWarnings("unchecked")
    public List<Object[]> findResumoFinanceiro(LocalDate inicio, LocalDate fim) {
        return entityManager
                .createNativeQuery("SELECT * FROM vw_resumo_financeiro WHERE data_operacao BETWEEN :inicio AND :fim")
                .setParameter("inicio", inicio)
                .setParameter("fim", fim)
                .getResultList();
    }

    @SuppressWarnings("unchecked")
    public List<Object[]> findPessoasJuridicas() {
        return entityManager.createNativeQuery("SELECT * FROM vw_pessoas_juridicas").getResultList();
    }

    @SuppressWarnings("unchecked")
    public List<Object[]> findPessoasFisicas() {
        return entityManager.createNativeQuery("SELECT * FROM vw_pessoas_fisicas").getResultList();
    }

    @SuppressWarnings("unchecked")
    public List<Object[]> findOperacoesDetalhadas() {
        return entityManager.createNativeQuery("SELECT * FROM vw_operacoes_detalhadas").getResultList();
    }

    @SuppressWarnings("unchecked")
    public List<Object[]> findEstoqueBaixo() {
        return entityManager.createNativeQuery("SELECT * FROM vw_estoque_baixo").getResultList();
    }

    public BigDecimal calcularTotalVendas() {
        String sql = "SELECT calcular_total_vendas()";
        return (BigDecimal) entityManager.createNativeQuery(sql).getSingleResult();
    }

    public BigDecimal calcularTotalCompras() {
        String sql = "SELECT calcular_total_compras()";
        return (BigDecimal) entityManager.createNativeQuery(sql).getSingleResult();
    }

    @SuppressWarnings("unchecked")
    public List<Object[]> calcularProdutosMaisVendidos() {
        String sql = "SELECT * FROM calcular_produtos_mais_vendidos()";
        return entityManager.createNativeQuery(sql).getResultList();
    }

}
