package br.com.sigas.entities;

import java.time.LocalDate;
import java.time.LocalDateTime;

import com.fasterxml.jackson.annotation.JsonBackReference;

import jakarta.persistence.*;

@Entity
@DiscriminatorValue("J")
@Table(name = "pessoas_juridicas")
public class PessoasJuridicas extends Pessoas {

    @Column(name = "cnpj", nullable = false, length = 18, unique = true)
    private String cnpj;

    @Column(name = "razao_social", nullable = false, length = 100)
    private String razao_social;

    @ManyToOne
    @JoinColumn(name = "id_pessoa", referencedColumnName = "id_pessoa", insertable = false, updatable = false)
    @JsonBackReference
    private Pessoas pessoa;

    public PessoasJuridicas() {
    }



    public PessoasJuridicas(long id_pessoa, String tipo_pessoa, String nome_pessoa, String email_pessoa,
            String endereco_pessoa, String tel1_pessoa, String tel2_pessoa, Boolean isActive, LocalDateTime dataCriacao,
            LocalDateTime dataModificacao, LocalDate dataNascimento, Integer idade, String cnpj, String razao_social,
            Pessoas pessoa) {
        super(id_pessoa, tipo_pessoa, nome_pessoa, email_pessoa, endereco_pessoa, tel1_pessoa, tel2_pessoa, isActive,
                dataCriacao, dataModificacao, dataNascimento, idade);
        this.cnpj = cnpj;
        this.razao_social = razao_social;
        this.pessoa = pessoa;
    }



    public PessoasJuridicas(String cnpj, String razao_social, Pessoas pessoa) {
        this.cnpj = cnpj;
        this.razao_social = razao_social;
        this.pessoa = pessoa;
    }



    public String getCnpj() {
        return cnpj;
    }

    public void setCnpj(String cnpj) {
        this.cnpj = cnpj;
    }

    public String getRazao_social() {
        return razao_social;
    }

    public void setRazao_social(String razao_social) {
        this.razao_social = razao_social;
    }

    public Pessoas getPessoa() {
        return pessoa;
    }

    public void setPessoa(Pessoas pessoa) {
        this.pessoa = pessoa;
    }

}
