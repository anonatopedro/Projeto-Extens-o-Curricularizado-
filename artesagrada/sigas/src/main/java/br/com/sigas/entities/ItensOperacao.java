package br.com.sigas.entities;

import java.math.BigDecimal;

import com.fasterxml.jackson.annotation.JsonBackReference;

import jakarta.persistence.*;

@Entity
@Table(name = "itens_operacao")
public class ItensOperacao {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id_item_operacao;

    @ManyToOne
    @JoinColumn(name = "id_operacao", nullable = false)
    @JsonBackReference
    private Operacoes operacao;

    @ManyToOne
    @JoinColumn(name = "id_produto", nullable = false)
    private Produtos produto;

    @Column(name = "quantidade", nullable = false)
    private Integer quantidade;

    @Column(name = "preco_unitario", nullable = false)
    private BigDecimal preco_unitario;

    @Column(name = "valor_total", precision = 10, scale = 2)
    private BigDecimal valor_total;

    @PrePersist
    @PreUpdate
    public void calcularValorTotal() {
        if (quantidade != null && preco_unitario != null) {
            this.valor_total = preco_unitario.multiply(new BigDecimal(quantidade));
        }
    }

    public ItensOperacao() {
    }

    public ItensOperacao(Long id_item_operacao, Operacoes operacao, Produtos produto, Integer quantidade,
            BigDecimal preco_unitario, BigDecimal valor_total) {
        this.id_item_operacao = id_item_operacao;
        this.operacao = operacao;
        this.produto = produto;
        this.quantidade = quantidade;
        this.preco_unitario = preco_unitario;
        this.valor_total = valor_total;
    }

    public Long getId_item_operacao() {
        return id_item_operacao;
    }

    public void setId_item_operacao(Long id_item_operacao) {
        this.id_item_operacao = id_item_operacao;
    }

    public Operacoes getOperacao() {
        return operacao;
    }

    public void setOperacao(Operacoes operacao) {
        this.operacao = operacao;
    }

    public Produtos getProduto() {
        return produto;
    }

    public void setProduto(Produtos produto) {
        this.produto = produto;
    }

    public Integer getQuantidade() {
        return quantidade;
    }

    public void setQuantidade(Integer quantidade) {
        this.quantidade = quantidade;
    }

    public BigDecimal getPreco_unitario() {
        return preco_unitario;
    }

    public void setPreco_unitario(BigDecimal preco_unitario) {
        this.preco_unitario = preco_unitario;
    }

    public BigDecimal getValor_total() {
        return valor_total;
    }

    public void setValor_total(BigDecimal valor_total) {
        this.valor_total = valor_total;
    }

}