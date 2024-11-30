package br.com.sigas.entities;

import java.time.LocalDate;
import java.time.LocalDateTime;

import com.fasterxml.jackson.annotation.JsonBackReference;

import jakarta.persistence.*;

@Entity
@DiscriminatorValue("F")
public class PessoasFisicas extends Pessoas {

    @Column(name = "cpf", nullable = false, length = 14, unique = true)
    private String cpf;

    @ManyToOne
    @JoinColumn(name = "id_pessoa", referencedColumnName = "id_pessoa", insertable = false, updatable = false)
    @JsonBackReference
    private Pessoas pessoa;

    public PessoasFisicas() {
    }

    

    public PessoasFisicas(long id_pessoa, String tipo_pessoa, String nome_pessoa, String email_pessoa,
            String endereco_pessoa, String tel1_pessoa, String tel2_pessoa, Boolean isActive, LocalDateTime dataCriacao,
            LocalDateTime dataModificacao, LocalDate dataNascimento, Integer idade, String cpf, Pessoas pessoa) {
        super(id_pessoa, tipo_pessoa, nome_pessoa, email_pessoa, endereco_pessoa, tel1_pessoa, tel2_pessoa, isActive,
                dataCriacao, dataModificacao, dataNascimento, idade);
        this.cpf = cpf;
        this.pessoa = pessoa;
    }



    public PessoasFisicas(String cpf, Pessoas pessoa) {
        this.cpf = cpf;
        this.pessoa = pessoa;
    }



    public String getCpf() {
        return cpf;
    }

    public void setCpf(String cpf) {
        this.cpf = cpf;
    }

    public Pessoas getPessoa() {
        return pessoa;
    }

    public void setPessoa(Pessoas pessoa) {
        this.pessoa = pessoa;
    }

}