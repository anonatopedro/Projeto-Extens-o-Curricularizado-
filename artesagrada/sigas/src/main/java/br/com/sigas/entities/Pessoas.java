package br.com.sigas.entities;

import java.time.LocalDate;
import java.time.LocalDateTime;
import jakarta.persistence.*;

@Entity
@Inheritance(strategy = InheritanceType.JOINED)
@DiscriminatorColumn(name = "tipo_pessoa", discriminatorType = DiscriminatorType.STRING)
@Table(name = "pessoas")
public class Pessoas {

    @Id
    @GeneratedValue(strategy = GenerationType.IDENTITY)
    private long id_pessoa;

    @Column(name = "tipo_pessoa", insertable = false, updatable = false)
    private String tipo_pessoa;

    @Column(name = "nome_pessoa", nullable = false, length = 100)
    private String nome_pessoa;

    @Column(name = "email_pessoa", length = 60)
    private String email_pessoa;

    @Column(name = "endereco_pessoa", length = 200)
    private String endereco_pessoa;

    @Column(name = "tel1_pessoa", nullable = false, length = 16)
    private String tel1_pessoa;

    @Column(name = "tel2_pessoa", length = 16)
    private String tel2_pessoa;

    @Column(name = "is_active", nullable = false)
    private Boolean isActive = true;

    @Column(name = "data_criacao", updatable = false)
    private LocalDateTime dataCriacao;

    @Column(name = "data_modificacao")
    private LocalDateTime dataModificacao;

    @Column(name = "data_nascimento", nullable = false)
    private LocalDate data_nascimento;

    @Column(name = "idade", insertable = false, updatable = false)
    private Integer idade; // A idade será gerada automaticamente pelo banco de dados

    @PrePersist
    protected void onCreate() {
        dataCriacao = LocalDateTime.now();
        dataModificacao = LocalDateTime.now();
    }

    @PreUpdate
    protected void onUpdate() {
        dataModificacao = LocalDateTime.now();
    }

    public Pessoas() {
    }

    public Pessoas(long id_pessoa, String tipo_pessoa, String nome_pessoa, String email_pessoa, String endereco_pessoa,
            String tel1_pessoa, String tel2_pessoa, Boolean isActive, LocalDateTime dataCriacao,
            LocalDateTime dataModificacao, LocalDate data_nascimento, Integer idade) {
        this.id_pessoa = id_pessoa;
        this.tipo_pessoa = tipo_pessoa;
        this.nome_pessoa = nome_pessoa;
        this.email_pessoa = email_pessoa;
        this.endereco_pessoa = endereco_pessoa;
        this.tel1_pessoa = tel1_pessoa;
        this.tel2_pessoa = tel2_pessoa;
        this.isActive = isActive;
        this.dataCriacao = dataCriacao;
        this.dataModificacao = dataModificacao;
        this.data_nascimento = data_nascimento;
        this.idade = idade;
    }

    // Getters e Setters
    public long getId_pessoa() {
        return id_pessoa;
    }

    public void setId_pessoa(long id_pessoa) {
        this.id_pessoa = id_pessoa;
    }

    public String getTipo_pessoa() {
        return tipo_pessoa;
    }

    public void setTipo_pessoa(String tipo_pessoa) {
        this.tipo_pessoa = tipo_pessoa;
    }

    public String getNome_pessoa() {
        return nome_pessoa;
    }

    public void setNome_pessoa(String nome_pessoa) {
        this.nome_pessoa = nome_pessoa;
    }

    public String getEmail_pessoa() {
        return email_pessoa;
    }

    public void setEmail_pessoa(String email_pessoa) {
        this.email_pessoa = email_pessoa;
    }

    public String getEndereco_pessoa() {
        return endereco_pessoa;
    }

    public void setEndereco_pessoa(String endereco_pessoa) {
        this.endereco_pessoa = endereco_pessoa;
    }

    public String getTel1_pessoa() {
        return tel1_pessoa;
    }

    public void setTel1_pessoa(String tel1_pessoa) {
        this.tel1_pessoa = tel1_pessoa;
    }

    public String getTel2_pessoa() {
        return tel2_pessoa;
    }

    public void setTel2_pessoa(String tel2_pessoa) {
        this.tel2_pessoa = tel2_pessoa;
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

    public LocalDate getDataNascimento() {
        return data_nascimento;
    }

    public void setDataNascimento(LocalDate dataNascimento) {
        this.data_nascimento = dataNascimento;
    }

    public Integer getIdade() {
        return idade;
    }
}