package br.com.sigas.repositories;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.jpa.repository.query.Procedure;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import br.com.sigas.entities.PessoasFisicas;

@Repository
public interface PessoasFisicasRepository extends JpaRepository<PessoasFisicas, Long> {

        @Query("SELECT p FROM PessoasFisicas p WHERE p.cpf = :cpf")
        Optional<PessoasFisicas> buscarPessoaFisicaPorCpf(@Param("cpf") String cpf);

        @Query("SELECT p FROM PessoasFisicas p WHERE p.id_pessoa = :id")
        Optional<PessoasFisicas> buscarPessoaFisicaPorId(@Param("id") long id);

        @Query("SELECT p FROM PessoasFisicas p WHERE LOWER(p.nome_pessoa) LIKE LOWER(CONCAT('%', :nome, '%'))")
        List<PessoasFisicas> buscarPessoaFisicaPorNome(@Param("nome") String nome);

        @Query("SELECT p FROM PessoasFisicas p WHERE LOWER(p.email_pessoa) LIKE LOWER(CONCAT('%', :email, '%'))")
        List<PessoasFisicas> buscarPessoaFisicaPorEmail(@Param("email") String email);

        @Procedure(procedureName = "inserir_pessoa_fisica")
        void inserirPessoaFisica(
                        @Param("id_pessoa") Long idPessoa,
                        @Param("cpf") String cpf);

        @Procedure(procedureName = "atualizar_pessoa_fisica")
        void atualizarPessoaFisica(
                        @Param("id_pessoa") Long idPessoa,
                        @Param("cpf_pessoa") String cpf,
                        @Param("nome_pessoa") String nome,
                        @Param("email_pessoa") String email,
                        @Param("endereco_pessoa") String endereco,
                        @Param("tel1_pessoa") String tel1,
                        @Param("tel2_pessoa") String tel2);

        @Procedure(procedureName = "deletar_pessoa_fisica")
        void deletarPessoaFisica(@Param("id_pessoa") Long idPessoa);
}
