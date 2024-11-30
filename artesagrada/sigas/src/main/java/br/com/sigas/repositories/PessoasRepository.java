package br.com.sigas.repositories;

import java.util.List;
import java.util.Optional;

import org.springframework.data.jpa.repository.JpaRepository;
import org.springframework.data.jpa.repository.Query;
import org.springframework.data.jpa.repository.query.Procedure;
import org.springframework.data.repository.query.Param;
import org.springframework.stereotype.Repository;

import br.com.sigas.entities.Pessoas;

@Repository
public interface PessoasRepository extends JpaRepository<Pessoas, Long> {

        @Query("SELECT p FROM Pessoas p WHERE p.id_pessoa = :id")
        Optional<Pessoas> buscarPessoaPorId(@Param("id") Long id);

        @Query("SELECT p FROM Pessoas p WHERE LOWER(p.nome_pessoa) LIKE LOWER(CONCAT('%', :nome, '%'))")
        List<Pessoas> buscarPessoasPorNome(@Param("nome") String nome);

        @Query("SELECT p FROM Pessoas p WHERE LOWER(p.email_pessoa) LIKE LOWER(CONCAT('%', :email, '%'))")
        List<Pessoas> buscarPessoasPorEmailContendo(@Param("email") String email);

        @Query("SELECT p FROM Pessoas p WHERE p.isActive = true")
        List<Pessoas> buscarPessoasAtivas();

        @Procedure(procedureName = "inserir_pessoa")
        void callInserirPessoa(
                        @Param("tipo_pessoa") String tipoPessoa,
                        @Param("nome") String nome,
                        @Param("email") String email,
                        @Param("endereco") String endereco,
                        @Param("tel1") String tel1,
                        @Param("tel2") String tel2);

        @Procedure(procedureName = "atualizar_pessoa")
        void callAtualizarPessoa(
                        @Param("id_pessoa") Long idPessoa,
                        @Param("nome") String nome,
                        @Param("email") String email,
                        @Param("endereco") String endereco,
                        @Param("tel1") String tel1,
                        @Param("tel2") String tel2);

        @Procedure(procedureName = "deletar_pessoa")
        void callDeletarPessoa(@Param("id_pessoa") Long idPessoa);
}
