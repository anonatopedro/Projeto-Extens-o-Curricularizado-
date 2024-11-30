package br.com.sigas.services;

import java.math.BigDecimal;
import java.time.LocalDate;
import java.util.ArrayList;
import java.util.HashMap;
import java.util.List;
import java.util.Map;

import org.springframework.beans.factory.annotation.Autowired;
import org.springframework.stereotype.Service;

import br.com.sigas.repositories.RelatoriosRepository;
import jakarta.persistence.EntityManager;
import jakarta.persistence.PersistenceContext;

@Service
public class RelatoriosService {

    @PersistenceContext
    private EntityManager entityManager;

    @Autowired
    private RelatoriosRepository relatoriosRepository;

    public List<Map<String, Object>> getOperacoesPorPeriodo(LocalDate inicio, LocalDate fim) {
        List<Object[]> rawData = relatoriosRepository.findOperacoesPorPeriodo(inicio, fim);
        return processarDadosRelatorio(rawData, "idOperacao", "tipoOperacao", "dataOperacao", "valorTotal");
    }

    public List<Map<String, Object>> getProdutosMaisVendidos(LocalDate inicio, LocalDate fim) {
        List<Object[]> rawData = relatoriosRepository.findProdutosMaisVendidos(inicio, fim);
        return processarDadosRelatorio(rawData, "idProduto", "nomeProduto", "quantidadeVendida", "valorTotal");
    }

    public List<Map<String, Object>> getEstoqueAtual() {
        List<Object[]> rawData = relatoriosRepository.findEstoqueAtual();
        return processarDadosRelatorio(rawData, "idProduto", "nomeProduto", "qtdEstoque", "precoUnidade");
    }

    public List<Map<String, Object>> getResumoFinanceiro(LocalDate inicio, LocalDate fim) {
        List<Object[]> rawData = relatoriosRepository.findResumoFinanceiro(inicio, fim);
        return processarDadosRelatorio(rawData, "tipoOperacao", "totalValor", "totalOperacoes", "dataOperacao");
    }

    public List<Map<String, Object>> getPessoasJuridicas() {
        List<Object[]> rawData = relatoriosRepository.findPessoasJuridicas();
        return processarDadosRelatorio(rawData, "id", "nome", "cnpj", "email", "telefone");
    }

    public List<Map<String, Object>> getPessoasFisicas() {
        List<Object[]> rawData = relatoriosRepository.findPessoasFisicas();
        return processarDadosRelatorio(rawData, "id", "nome", "cpf", "email", "telefone");
    }

    public List<Map<String, Object>> getOperacoesDetalhadas() {
        List<Object[]> rawData = relatoriosRepository.findOperacoesDetalhadas();
        return processarDadosRelatorio(rawData, "idOperacao", "idPessoa", "tipoOperacao", "dataOperacao", "valorTotal");
    }

    public List<Map<String, Object>> getEstoqueBaixo() {
        List<Object[]> rawData = relatoriosRepository.findEstoqueBaixo();
        return processarDadosRelatorio(rawData, "idProduto", "nomeProduto", "qtdEstoque", "precoUnidade");
    }

    public BigDecimal calcularTotalVendas() {
        String sql = "SELECT calcular_total_vendas()";
        return (BigDecimal) entityManager.createNativeQuery(sql).getSingleResult();
    }

    public BigDecimal calcularTotalCompras() {
        String sql = "SELECT calcular_total_compras()";
        return (BigDecimal) entityManager.createNativeQuery(sql).getSingleResult();
    }

    public List<Map<String, Object>> calcularProdutosMaisVendidos() {
        String sql = "SELECT * FROM calcular_produtos_mais_vendidos()";
        @SuppressWarnings("unchecked")
        List<Object[]> rawData = entityManager.createNativeQuery(sql).getResultList();

        List<Map<String, Object>> produtosMaisVendidos = new java.util.ArrayList<>();
        for (Object[] row : rawData) {
            Map<String, Object> produto = new HashMap<>();
            produto.put("idProduto", row[0]);
            produto.put("nomeProduto", row[1]);
            produto.put("quantidadeVendida", row[2]);
            produtosMaisVendidos.add(produto);
        }
        return produtosMaisVendidos;
    }

    private List<Map<String, Object>> processarDadosRelatorio(List<Object[]> rawData, String... keys) {
        List<Map<String, Object>> dados = new ArrayList<>();
        for (Object[] row : rawData) {
            Map<String, Object> item = new HashMap<>();
            for (int i = 0; i < keys.length; i++) {
                item.put(keys[i], row[i]);
            }
            dados.add(item);
        }
        return dados;
    }
}
