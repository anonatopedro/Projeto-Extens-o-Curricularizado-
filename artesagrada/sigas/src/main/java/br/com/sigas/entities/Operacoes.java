package br.com.sigas.entities;

import java.time.LocalDate;
import java.util.List;

import com.fasterxml.jackson.annotation.JsonIgnoreProperties;
import com.fasterxml.jackson.annotation.JsonManagedReference;

import jakarta.persistence.*;

@Entity
@Table(name = "operacoes")
public class Operacoes {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private Integer id_operacao;

    @ManyToOne
    @JoinColumn(name = "id_pessoa", nullable = false)
    private Pessoas pessoa;

    @Column(name = "tipo_operacao", nullable = false)
    private Character tipo_operacao;

    @Column(name = "data_operacao", nullable = false)
    private LocalDate data_operacao;

    @Column(name = "valor_total", nullable = false)
    private Double valor_total;

    @OneToMany(mappedBy = "operacao", cascade = CascadeType.ALL, orphanRemoval = true)
    @JsonIgnoreProperties("operacao")
    @JsonManagedReference
    private List<ItensOperacao> itens_operacao;

    public Operacoes() {
    }

    public Operacoes(Integer id_operacao, Pessoas pessoa, Character tipo_operacao, LocalDate data_operacao,
            Double valor_total, List<ItensOperacao> itens_operacao) {
        this.id_operacao = id_operacao;
        this.pessoa = pessoa;
        this.tipo_operacao = tipo_operacao;
        this.data_operacao = data_operacao;
        this.valor_total = valor_total;
        this.itens_operacao = itens_operacao;
    }

    public Integer getId_operacao() {
        return id_operacao;
    }

    public void setId_operacao(Integer id_operacao) {
        this.id_operacao = id_operacao;
    }

    public Pessoas getPessoa() {
        return pessoa;
    }

    public void setPessoa(Pessoas pessoa) {
        this.pessoa = pessoa;
    }

    public Character getTipo_operacao() {
        return tipo_operacao;
    }

    public void setTipo_operacao(Character tipo_operacao) {
        this.tipo_operacao = tipo_operacao;
    }

    public LocalDate getData_operacao() {
        return data_operacao;
    }

    public void setData_operacao(LocalDate data_operacao) {
        this.data_operacao = data_operacao;
    }

    public Double getValor_total() {
        return valor_total;
    }

    public void setValor_total(Double valor_total) {
        this.valor_total = valor_total;
    }

    public List<ItensOperacao> getItens_operacao() {
        return itens_operacao;
    }

    public void setItens_operacao(List<ItensOperacao> itens_operacao) {
        this.itens_operacao = itens_operacao;
    }

}