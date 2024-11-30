package br.com.sigas.entities;

import java.math.BigDecimal;
import java.time.LocalDateTime;

import com.fasterxml.jackson.annotation.JsonBackReference;

import jakarta.persistence.*;

@Entity
@Table(name = "Produtos")
public class Produtos {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Long id_produto;

    @Column(name = "nome_produto", nullable = false, length = 50)
    private String nome_produto;

    @Column(name = "descricao", nullable = false, length = 200)
    private String descricao;

    @Column(name = "unidade", nullable = false, length = 10)
    private String unidade;

    @Column(name = "preco_unidade", nullable = false, precision = 10, scale = 2)
    private BigDecimal preco_unidade;

    @Column(name = "qtd_estoque", nullable = false)
    private Integer qtd_estoque;

    @Column(name = "is_active", nullable = false)
    private Boolean isActive = true;

    @Column(name = "data_criacao", updatable = false)
    private LocalDateTime dataCriacao;

    @Column(name = "data_modificacao")
    private LocalDateTime dataModificacao;

    @ManyToOne
    @JoinColumn(name = "id_categoria", nullable = false)
    @JsonBackReference
    private Categorias categoria;

    @PrePersist
    protected void onCreate() {
        dataCriacao = LocalDateTime.now();
        dataModificacao = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        dataModificacao = LocalDateTime.now();
    }

    public Produtos() {
    }

    public Produtos(Long id_produto, String nome_produto, String descricao, String unidade, BigDecimal preco_unidade,
            Integer qtd_estoque, Boolean isActive, LocalDateTime dataCriacao, LocalDateTime dataModificacao,
            Categorias categoria) {
        this.id_produto = id_produto;
        this.nome_produto = nome_produto;
        this.descricao = descricao;
        this.unidade = unidade;
        this.preco_unidade = preco_unidade;
        this.qtd_estoque = qtd_estoque;
        this.isActive = isActive;
        this.dataCriacao = dataCriacao;
        this.dataModificacao = dataModificacao;
        this.categoria = categoria;
    }

    public Long getId_produto() {
        return id_produto;
    }

    public void setId_produto(Long id_produto) {
        this.id_produto = id_produto;
    }

    public String getNome_produto() {
        return nome_produto;
    }

    public void setNome_produto(String nome_produto) {
        this.nome_produto = nome_produto;
    }

    public String getDescricao() {
        return descricao;
    }

    public void setDescricao(String descricao) {
        this.descricao = descricao;
    }

    public String getUnidade() {
        return unidade;
    }

    public void setUnidade(String unidade) {
        this.unidade = unidade;
    }

    public BigDecimal getPreco_unidade() {
        return preco_unidade;
    }

    public void setPreco_unidade(BigDecimal preco_unidade) {
        this.preco_unidade = preco_unidade;
    }

    public Integer getQtd_estoque() {
        return qtd_estoque;
    }

    public void setQtd_estoque(Integer qtd_estoque) {
        this.qtd_estoque = qtd_estoque;
    }

    public Boolean getIsActive() {
        return isActive;
    }

    public void setIsActive(Boolean isActive) {
        this.isActive = isActive;
    }

    public LocalDateTime getDataCriacao() {
        return dataCriacao;
    }

    public void setDataCriacao(LocalDateTime dataCriacao) {
        this.dataCriacao = dataCriacao;
    }

    public LocalDateTime getDataModificacao() {
        return dataModificacao;
    }

    public void setDataModificacao(LocalDateTime dataModificacao) {
        this.dataModificacao = dataModificacao;
    }

    public Categorias getCategoria() {
        return categoria;
    }

    public void setCategoria(Categorias categoria) {
        this.categoria = categoria;
    }

}
